{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.AdmEstoque where

import Foundation
import Yesod.Core

import Yesod                    -- runDB, Entity e outros
import Yesod.Auth               -- auth
import Database.Persist.Sql     -- banco de dados (rawSQL)

type Form x = Html -> MForm Handler (FormResult x, Widget)  -- cria sinonimo para Form

getAdmEstoqueR :: Handler Html
getAdmEstoqueR = do
    listaEstoques <- runDB $ (rawSql "SELECT ??, ??, ?? \
                             \FROM estoque_vac_est INNER JOIN vacina \
                             \ON estoque_vac_est.p_vacina=vacina.id \
                             \INNER JOIN estado \
                             \ON estoque_vac_est.p_estado=estado.id" [])::Handler [(Entity EstoqueVacEst, Entity Vacina, Entity Estado)]
    ((_, widget), enctype) <- runFormPost $ formEstoque
    defaultLayout $ do
        varId <- maybeAuthId
        setTitle "Rastreador de Vacinas"
        [whamlet|
            <code>
                <dd> <h2>Gerenciador de Estoques
                <hr>

                $maybe val <- varId
                    <h3 style="float:left;"> <a href=@{AdminR}>Voltar</a>
                    <h3 style="float:right;"> <a href=@{AuthR LogoutR}>(id: #{val}) Logout</a>
                        &nbsp;
                $nothing
                    <h3 style="float:left;"> <a href=@{AdminR}>Voltar</a>
                    <h3 style="float:right;"> <a href=@{AuthR LoginR}>Login</a>
                        &nbsp;

                <br> <br>
                    <dd>
                        <h3>Estoques Cadastrados:
                        $forall (Entity estqId estoque, Entity _ vacina, Entity _ estado) <- listaEstoques
                            <p>Estado: #{estadoNome estado} (#{estadoSigla estado}) - #{estoqueVacEstNumero estoque} doses de #{vacinaNome vacina} (
                                eficacia: #{vacinaEficacia vacina}%)
                                (<a href=@{AdmEstoqueDR estqId}>Deslistar</a>)

            <hr>
                <code>
                    <center>
                        <h3> Cadastrar Novo Estoque
                        <form method=post action=@{AdmEstoqueR} enctype=#{enctype}>
                            ^{widget}
                            <input type=submit value=Cadastrar Estoque>
                            <pre>

            <hr>
                <code>
                    <p> <center>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
        |]

postAdmEstoqueR :: Handler Html
postAdmEstoqueR = do
    ((result, _), _) <- runFormPost formEstoque
    case result of
        FormSuccess est -> do
            runDB $ insert est
            redirect (AdmEstoqueR)
        _ -> error "Problema com Cadastro do Estoque"

formEstoque :: Form EstoqueVacEst
formEstoque = renderDivs $ EstoqueVacEst
    <$> areq (selectField vacs) "Vacina" Nothing
    <*> areq (selectField ests) "Estado" Nothing
    <*> areq intField "Numero" Nothing
    where
        vacs = do
            entvac <- runDB $ selectList [] [Asc VacinaNome]
            optionsPairs $ fmap (\ent -> (vacinaNome $ entityVal ent, entityKey ent)) entvac
        ests = do
            entest <- runDB $ selectList [] [Asc EstadoSigla]
            optionsPairs $ fmap (\ent -> (estadoSigla $ entityVal ent, entityKey ent)) entest
