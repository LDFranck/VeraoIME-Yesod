{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.AdmVacinaU where

import Foundation
import Yesod.Core

import Yesod.Auth   -- auth
import Yesod        -- necessario para runDB $ ...

getAdmVacinaUR :: VacinaId -> Handler Html
getAdmVacinaUR vacid = do
    vacina <- runDB $ get404 vacid  -- caso nao encontra Id, retorna pagina 404 Not Found
    let nome = vacinaNome vacina
        eficacia = vacinaEficacia vacina
    defaultLayout $ do
        varId <- maybeAuthId
        setTitle "Rastreador de Vacinas"
        [whamlet|
            <code>
                <dd> <h2>Atualizar Cadastro de Vacina
                <hr>

                $maybe val <- varId
                    <h3 style="float:left;"> <a href=@{AdmVacinaR}>Voltar</a>
                    <h3 style="float:right;"> <a href=@{AuthR LogoutR}>(id: #{val}) Logout</a>
                        &nbsp;
                $nothing
                    <h3 style="float:left;"> <a href=@{AdmVacinaR}>Voltar</a>
                    <h3 style="float:right;"> <a href=@{AuthR LoginR}>Login</a>
                        &nbsp;

                <br> <br>
                    <dd>
                        <h3>Dados Atuais:
                        <p>Nome: #{nome}; Eficacia: #{eficacia}%;

            <hr>
                <code>
                    <center>
                        <h3> Atualizar Dados da Vacina
                        <form action=@{AdmVacinaUR vacid} method=post>
                            <pre>Nome:     <input type="text" name="nome" value=#{nome}>
                            <pre>Eficacia: <input type="number" name="eficacia" min="0" max="100" value=#{eficacia}>
                            <pre><input type=submit value="Atualizar Vacina">

            <hr>
                <code>
                    <p> <center>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
        |]

postAdmVacinaUR :: VacinaId -> Handler Html
postAdmVacinaUR vacid = do
    vacina <- runInputPost $ Vacina
        <$> ireq textField "nome"
        <*> ireq intField "eficacia"
    runDB $ update vacid [VacinaNome =. (vacinaNome vacina), VacinaEficacia =. (vacinaEficacia vacina)]
    redirect (AdmVacinaR)
