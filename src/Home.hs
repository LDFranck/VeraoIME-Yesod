{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module Home where

import Foundation
import Yesod.Core

import Yesod.Auth   -- auth

getHomeR :: Handler Html
getHomeR = defaultLayout $ do
    mayId <- maybeAuthId
    setTitle "Rastreador de Vacinas"    -- nome da pagina / aba
    [whamlet|
    <code>
        <center> <h1>Rastreador de Vacinas - Brasil
        <hr>

        $maybe val <- mayId
            <h3 style="text-align:right;"> <a href=@{AuthR LogoutR}>(id: #{val}) Logout</a>
                &nbsp;
        $nothing
            <h3 style="text-align:right;"> <a href=@{AuthR LoginR}>Login</a>
                &nbsp;

        <dd> <h2>
            <a href=@{DistribuicaoR}>Distribuição Nacional</a>
            <p> <a href=@{AdminR}>Painel do Administrador</a>
            <br>
    <hr>
    <p> <center>
        <img src=@{StaticR brasil_png}/>
        <br> <code>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
|]
