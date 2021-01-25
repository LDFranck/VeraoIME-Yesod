{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE ViewPatterns      #-}

{-# LANGUAGE MultiParamTypeClasses #-}  -- necessario para RenderMessage

-- ALGUM DESSES PRECISA PARA O DERIVING DAS TABELAS
{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleInstances,
             MultiParamTypeClasses, DeriveDataTypeable,
             GeneralizedNewtypeDeriving, ViewPatterns, EmptyDataDecls#-}

{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
-- DESCOBRIR E APAGAR OS DESNECESSARIOS

module Foundation where

import Yesod.Core

import Database.Persist.Postgresql      -- banco de dados

import Yesod                            -- necessario para RenderMessage
import Data.Text (Text)                 -- tipo de dado Text

import Network.HTTP.Conduit (Manager)   -- auth
import Yesod.Auth                       -- auth
import Yesod.Auth.Dummy                 -- auth

import Yesod.Static     -- imagem
staticFiles "static"    -- imagem

-- INICIO DO BLOCO DA ESTRUTURA DO BANCO DE DADOS:
-- share = cria o banco de dados
-- Para cada tabela o Persist cria automaticamente um Id oculto
share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
    Vacina
        nome Text
        eficacia Int
        deriving Show
    Estado
        nome Text
        sigla Text
        deriving Show
    EstoqueVacEst
        pVacina VacinaId
        pEstado EstadoId
        numero Int
        deriving Show
|]
-- FIM DO BLOCO DA ESTRUTURA DO BANCO DE DADOS

data App = App {connPool :: ConnectionPool, httpManager :: Manager, getStatic :: Static}    -- banco + auth + imagem -> CUIDAR ORDEM
mkYesodData "App" $(parseRoutesFile "routes.yesodroutes")

instance Yesod App where
-- INICIO DO BLOCO AUTH:

    -- Inicio bloco opcional (sessao de 5 minutos):
    makeSessionBackend _ = do
        backend <- defaultClientSessionBackend 5 "keyfile.aes"  -- 5 = minutos
        return $ Just backend
     -- Fim do bloco opcional (sessao de 5 minutos)

    authRoute _ = Just $ AuthR LoginR       -- determina pagina de Login como AuthR LoginR.
    -- Se isAuthorized retorna AuthenticationRequired, redireciona para AuthR LoginR

    -- isAuthorized <PaginaR> <True se for writeRequest> = ehAutorizado (funcao verifica)
    isAuthorized AdminR _ = isAdmin

    isAuthorized AdmVacinaR _ = isAdmin
    isAuthorized (AdmVacinaUR _) _ = isAdmin
    isAuthorized (AdmVacinaDR _) _ = isAdmin

    isAuthorized AdmEstadoR _ = isAdmin
    isAuthorized (AdmEstadoUR _) _ = isAdmin
    isAuthorized (AdmEstadoDR _) _ = isAdmin

    isAuthorized AdmEstoqueR _ = isAdmin
    isAuthorized (AdmEstoqueDR _) _ = isAdmin

    isAuthorized _ _ = return Authorized    -- autoriza usuario a qualquer pagina

instance YesodAuth App where
    type AuthId App = Text
    authenticate = return . Authenticated . credsIdent
    loginDest _ = HomeR             -- destino apos login
    logoutDest _ = HomeR            -- destino apos logout
    authPlugins _ = [authDummy]     -- autenticador Dummy (id = input no login)
    maybeAuthId = lookupSession "_ID"
-- FIM DO BLOCO AUTH

instance RenderMessage App FormMessage where    -- Mensagens padrao
    renderMessage _ _ = defaultFormMessage

-- INICIO DO BLOCO DE FUNCOES DE AUTORIZACAO:
isAdmin :: Handler AuthResult
isAdmin = do
    mayId <- maybeAuthId
    return $ case mayId of
        Nothing -> AuthenticationRequired
        Just "admin" -> Authorized
        Just _ -> Unauthorized "Apenas admin eh autorizado."
-- FIM DO BLOCO DE FUNCOES DE AUTORIZACAO

-- INICIO DO BLOCO DE INSTANCE DE ACESSO AO BD:
instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend
    runDB action = do
        master <- getYesod
        let pool = connPool master
        runSqlPool action pool
-- FIM DO BLOCO DE INSTANCE DE ACESSO AO BD
