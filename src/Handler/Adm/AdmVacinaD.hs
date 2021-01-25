-- OK, mas com o bug de exclusao quando faz parte de um Estoque
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.AdmVacinaD where

import Foundation
import Yesod.Core

import Yesod    -- necessario para o runDB $ delete vacid

getAdmVacinaDR :: VacinaId -> Handler Html
getAdmVacinaDR vacid = do
    runDB $ delete vacid
    redirect (AdmVacinaR)
