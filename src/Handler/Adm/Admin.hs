{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.Admin where

import Foundation
import Yesod.Core

import Yesod.Auth   -- auth

getAdminR :: Handler Html
getAdminR = defaultLayout $ do
    varId <- maybeAuthId
    setTitle "Rastreador de Vacinas"
    [whamlet|
        <code>
            <dd> <h2>Painel do Administrador
            <hr>

            $maybe val <- varId
                <h3 style="float:left;"> <a href=@{HomeR}>Voltar</a>
                <h3 style="float:right;"> <a href=@{AuthR LogoutR}>(id: #{val}) Logout</a>
                    &nbsp;
            $nothing
                <h3 style="float:left;"> <a href=@{HomeR}>Voltar</a>
                <h3 style="float:right;"> <a href=@{AuthR LoginR}>Login</a>
                    &nbsp;

            <dd> <h2>
                <br> <br> <a href=@{AdmVacinaR}>Gerenciar Vacinas</a>
                <p> <a href=@{AdmEstadoR}>Gerenciar Estados</a>
                <p> <a href=@{AdmEstoqueR}>Gerenciar Estoques</a>
                <br>
        <hr>
        <p> <center>
            <code>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
    |]
