{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.AdmEstoqueD where

import Foundation
import Yesod.Core

import Yesod    -- necessario para o runDB $ delete vacid

getAdmEstoqueDR :: EstoqueVacEstId -> Handler Html
getAdmEstoqueDR estqid = do
    runDB $ delete estqid
    redirect (AdmEstoqueR)
