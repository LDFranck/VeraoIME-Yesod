-- OK, mas com o bug de exclusao quando faz parte de um Estoque
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.AdmEstadoD where

import Foundation
import Yesod.Core

import Yesod    -- necessario para o runDB $ delete vacid

getAdmEstadoDR :: EstadoId -> Handler Html
getAdmEstadoDR estid = do
    runDB $ delete estid
    redirect (AdmEstadoR)
