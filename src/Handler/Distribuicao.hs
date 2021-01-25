{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Distribuicao where

import Foundation
import Yesod.Core

import Yesod.Auth   -- auth

getDistribuicaoR :: Handler Html
getDistribuicaoR = defaultLayout $ do
    varId <- maybeAuthId
    setTitle "Rastreador de Vacinas"
    [whamlet|
        <code>
            <dd> <h2>Distribuição Nacional
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
                <br> <br> <a href=@{DistEstadoR}>Estoque de Vacinas dos Estados</a>
                <p> <a href=@{DistVacinaR}>Relação das Vacinas Encaminhadas</a>
                <br>
        <hr>
        <p> <center>
            <code>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
    |]
