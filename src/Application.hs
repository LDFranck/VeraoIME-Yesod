{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE ViewPatterns         #-}

{-# OPTIONS_GHC -fno-warn-orphans #-}
module Application where

import Foundation
import Yesod.Core

import Yesod.Auth   -- auth

import Home

import Handler.Distribuicao
import Handler.DistEstado
import Handler.DistVacina

import Handler.Adm.Admin

import Handler.Adm.AdmVacina
import Handler.Adm.AdmVacinaU
import Handler.Adm.AdmVacinaD

import Handler.Adm.AdmEstado
import Handler.Adm.AdmEstadoU
import Handler.Adm.AdmEstadoD

import Handler.Adm.AdmEstoque
import Handler.Adm.AdmEstoqueD

mkYesodDispatch "App" resourcesApp
