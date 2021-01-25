{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.AdmEstadoU where

import Foundation
import Yesod.Core

import Yesod.Auth   -- auth
import Yesod        -- necessario para runDB $ ...

getAdmEstadoUR :: EstadoId -> Handler Html
getAdmEstadoUR estid = do
    estado <- runDB $ get404 estid  -- caso nao encontra Id, retorna pagina 404 Not Found
    let nome = estadoNome estado
        sigla = estadoSigla estado
    defaultLayout $ do
        varId <- maybeAuthId
        setTitle "Rastreador de Vacinas"
        [whamlet|
            <code>
                <dd> <h2>Atualizar Cadastro de Estado
                <hr>

                $maybe val <- varId
                    <h3 style="float:left;"> <a href=@{AdmEstadoR}>Voltar</a>
                    <h3 style="float:right;"> <a href=@{AuthR LogoutR}>(id: #{val}) Logout</a>
                        &nbsp;
                $nothing
                    <h3 style="float:left;"> <a href=@{AdmEstadoR}>Voltar</a>
                    <h3 style="float:right;"> <a href=@{AuthR LoginR}>Login</a>
                        &nbsp;

                <br> <br>
                    <dd>
                        <h3>Dados Atuais:
                        <p>Nome: #{nome}; Sigla: #{sigla};

            <hr>
                <code>
                    <center>
                        <h3> Atualizar Dados do Estado
                        <form action=@{AdmEstadoUR estid} method=post>
                            <pre>Nome:  <input type="text" name="nome" value=#{nome}>
                            <pre>Sigla: <input type="text" name="sigla" maxlength="2" value=#{sigla}>
                            <pre><input type=submit value="Atualizar Estado">

            <hr>
                <code>
                    <p> <center>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
        |]

postAdmEstadoUR :: EstadoId -> Handler Html
postAdmEstadoUR estid = do
    estado <- runInputPost $ Estado
        <$> ireq textField "nome"
        <*> ireq textField "sigla"
    runDB $ update estid [EstadoNome =. (estadoNome estado), EstadoSigla =. (estadoSigla estado)]
    redirect (AdmEstadoR)
