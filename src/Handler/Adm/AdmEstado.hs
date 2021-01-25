{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.AdmEstado where

import Foundation
import Yesod.Core

import Yesod.Auth   -- auth
import Yesod        -- necessario para Entity

getAdmEstadoR :: Handler Html
getAdmEstadoR = do
    listaEstados <- runDB $ selectList [] [Asc EstadoId]
    defaultLayout $ do
        varId <- maybeAuthId
        setTitle "Rastreador de Vacinas"
        [whamlet|
            <code>
                <dd> <h2>Gerenciador de Estados
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
                        <h3>Estados Cadastrados:
                        $forall (Entity estId estado) <- listaEstados
                            <p>Nome: #{estadoNome estado}; Sigla: #{estadoSigla estado}; (
                                <a href=@{AdmEstadoUR estId}>Atualizar</a> , <a href=@{AdmEstadoDR estId}>Deslistar</a>)

            <hr>
                <code>
                    <center>
                        <h3> Cadastrar Novo Estado
                        <form action=@{AdmEstadoR} method=post>
                            <pre>Nome:  <input type="text" name="nome">
                            <pre>Sigla: <input type="text" name="sigla" maxlength="2">
                            <pre><input type=submit value="Cadastrar Estado">

            <hr>
                <code>
                    <p> <center>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
        |]

postAdmEstadoR :: Handler Html
postAdmEstadoR = do
    estado <- runInputPost $ Estado
        <$> ireq textField "nome"
        <*> ireq textField "sigla"
    runDB $ insert estado
    redirect (AdmEstadoR)
