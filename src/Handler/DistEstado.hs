{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.DistEstado where

import Foundation
import Yesod.Core

import Yesod                    -- runDB, Entity e outros
import Yesod.Auth               -- auth
import Database.Persist.Sql     -- banco de dados (rawSQL)

getDistEstadoR :: Handler Html
getDistEstadoR = do
    listaEstados <- runDB $ selectList [] [Asc EstoqueVacEstPEstado]
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
                <dd> <h2>Estoque de Vacinas dos Estados
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
                            $forall (Entity id _) <- listaEstados
                                $forall(Entity idaux estq, Entity _ vacina, Entity _ est) <- listaEstoques
                                    $if id == idaux
                                        <p>#{estadoNome est} (#{estadoSigla est}): #{estoqueVacEstNumero estq} doses da #{vacinaNome vacina} (
                                            eficacia: #{vacinaEficacia vacina}%)

            <hr>
                <code>
                    <p> <center>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
        |]
