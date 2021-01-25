{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.DistVacina where

import Foundation
import Yesod.Core

import Yesod                    -- runDB, Entity e outros
import Yesod.Auth               -- auth
import Database.Persist.Sql     -- banco de dados (rawSQL)

getDistVacinaR :: Handler Html
getDistVacinaR = do
    listaVacinas <- runDB $ selectList [] [Asc EstoqueVacEstPVacina]
    listaEstoques <- runDB $ (rawSql "SELECT ??, ??, ?? \
                             \FROM estoque_vac_est INNER JOIN vacina \
                             \ON estoque_vac_est.p_vacina=vacina.id \
                             \INNER JOIN estado \
                             \ON estoque_vac_est.p_estado=estado.id" [])::Handler [(Entity EstoqueVacEst, Entity Vacina, Entity Estado)]
    defaultLayout $ do
        varId <- maybeAuthId
        setTitle "Rastreador de Vacinas"
        [whamlet|
            <code>
                <dd> <h2>Relação das Vacinas Encaminhadas
                <hr>

                $maybe val <- varId
                    <h3 style="float:left;"> <a href=@{DistribuicaoR}>Voltar</a>
                    <h3 style="float:right;"> <a href=@{AuthR LogoutR}>(id: #{val}) Logout</a>
                        &nbsp;
                $nothing
                    <h3 style="float:left;"> <a href=@{DistribuicaoR}>Voltar</a>
                    <h3 style="float:right;"> <a href=@{AuthR LoginR}>Login</a>
                        &nbsp;

                <br> <br>
                    <dd>
                        <h3>
                            $forall (Entity id _) <- listaVacinas
                                $forall(Entity idaux estq, Entity _ vacina, Entity _ est) <- listaEstoques
                                    $if id == idaux
                                        <p> #{vacinaNome vacina} (eficacia: #{vacinaEficacia vacina}%): #{estoqueVacEstNumero estq} doses encaminhadas para #{estadoNome est} (#{estadoSigla est})

            <hr>
                <code>
                    <p> <center>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
        |]
