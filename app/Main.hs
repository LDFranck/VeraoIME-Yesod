{-# LANGUAGE OverloadedStrings #-}      -- necessario para connStr (banco de dados)

import Application () -- for YesodDispatch instance
import Foundation
import Yesod.Core

import Network.HTTP.Conduit (newManager, tlsManagerSettings)    -- auth

import Yesod.Static     -- imagem

import Database.Persist.Postgresql                  -- banco de dados (PostgreSQL)
import Control.Monad.Logger (runStdoutLoggingT)     -- banco de dados (runStdoutLoggingT)

import System.Environment (getEnv)                  -- Heroku

connStr = "dbname=de18h43fftuf04 host=ec2-52-72-190-41.compute-1.amazonaws.com user=pmoilydyfkesrx password=4d65b2ea374e24dfe70757c65de7bc709f4b86dc8c91e07cc88e083500e5c575 port=5432"   -- parametros de acesso ao BD

main :: IO ()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do     -- banco de dados
    runSqlPersistMPool (runMigration migrateAll) pool                               -- banco de dados
    manager <- newManager tlsManagerSettings        -- auth
    static@(Static settings) <- static "static"     -- imagem
    port <- getEnv "PORT"                           -- porta Heroku
    warp (read port) (App pool manager static)             -- banco + auth + imagem -> CUIDAR ORDEM (Foundation)

-- runStderrLoggingT = permite debug no console (todas requisicoes ficam visiveis)
-- withPostgresqlPool = abre uma conexao com o banco de dados do tipo Postgresql
-- connStr = string de conexao com os dados necessarios; o 10 eh o numero de sockets
-- runSqlPersistMPool (runMigration migrateAll) pool = mantem conexao e cria estrutura do banco
-- manager <- newManager tlsManagerSettings = gerenciador do HTTP necessario para Auth
-- static@(Static settings) <- static "static" = cria um tipo static e linka com a pasta origem
