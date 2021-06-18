/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Leandro Bissoli na aula do Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
Projeto para criar um smart contract que funciona como listagem de partidas e acompanhamento de seus resultados (ORACLE de Partidas)
*/

pragma solidity >=0.7.0 <0.9.0;

import  './OraclePartidas.sol';

contract PartidaInteface {
    
  /* struct partida {
        uint dataRegistro;
        string time1_Casa;
        string time2_Visitante;
        uint timeVencedor;
        bool resultadoAtualizado;
    }*/

    OraclePartidas internal contratoPartidas;
    
    
    constructor (address _enderecoContrato){
        contratoPartidas =  OraclePartidas(_enderecoContrato);
        
    }

    function retornarPartida(uint _idPartida) public view returns (uint _idTimeVencedor, string memory _time1_Casa, string memory _time2_Visitante){
        uint idTimeVencedor;
        string memory time1_Casa;
        string memory time2_Visitante;
        
        // RECEBO AS VARIÁVEIS
        (idTimeVencedor, time1_Casa, time2_Visitante) = contratoPartidas.retornarPartida(_idPartida);
       
        return (idTimeVencedor, time1_Casa, time2_Visitante);
    }
}
