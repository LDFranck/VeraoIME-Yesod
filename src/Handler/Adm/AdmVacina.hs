{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Handler.Adm.AdmVacina where

import Foundation
import Yesod.Core

import Yesod.Auth   -- auth
import Yesod        -- necessario para runDB $ ...

getAdmVacinaR :: Handler Html
getAdmVacinaR = do
    listaVacinas <- runDB $ selectList [] [Asc VacinaId]
    defaultLayout $ do
        varId <- maybeAuthId
        setTitle "Rastreador de Vacinas"
        [whamlet|
            <code>
                <dd> <h2>Gerenciador de Vacinas
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
                        <h3>Vacinas Cadastradas:
                        $forall (Entity vacId vacina) <- listaVacinas
                            <p>Nome: #{vacinaNome vacina}; Eficacia: #{vacinaEficacia vacina}%; (
                                <a href=@{AdmVacinaUR vacId}>Atualizar</a> , <a href=@{AdmVacinaDR vacId}>Deslistar</a>)

            <hr>
                <code>
                    <center>
                        <h3> Cadastrar Nova Vacina
                        <form action=@{AdmVacinaR} method=post>
                            <pre>Nome:     <input type="text" name="nome">
                            <pre>Eficacia: <input type="number" name="eficacia" min="0" max="100">
                            <pre><input type=submit value="Cadastrar Vacina">

            <hr>
                <code>
                    <p> <center>Made by <a href="https://github.com/LDFranck">@LDFranck</a>
        |]

postAdmVacinaR :: Handler Html
postAdmVacinaR = do
    vacina <- runInputPost $ Vacina
        <$> ireq textField "nome"
        <*> ireq intField "eficacia"
    runDB $ insert vacina
    redirect (AdmVacinaR)
