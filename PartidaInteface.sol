/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Leandro Bissoli na aula do Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
Projeto para criar um smart contract que funciona como listagem de partidas e acompanhamento de seus resultados (ORACLE de Partidas)
*/

pragma solidity >=0.7.0 <0.9.0;

import  './OraclePartidas.sol';

contract PartidaInteface {
    
    struct partida {
        uint dataRegistro;
        string time1_Casa;
        string time2_Visitante;
        uint timeVencedor;
        bool resultadoAtualizado;
    }
    partida[] public Partidas;
    
    address public nomeAdmin;
    
    OraclePartidas internal contratoPartidas;
    
    
    constructor (address _enderecoContrato){
        contratoPartidas =  OraclePartidas(_enderecoContrato);
        
    }
   
   function listarPartidasContrato() public view returns (address){
      // Partidas = contratoPartidas.listarPartidas();
      // return nomeAdmin;
    }
}
