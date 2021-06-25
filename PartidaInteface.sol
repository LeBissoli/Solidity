/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Leandro Bissoli na aula do Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
Projeto para criar um smart contract que funciona como listagem de partidas e acompanhamento de seus resultados (ORACLE de Partidas)
*/

pragma solidity >=0.7.0 <0.9.0;

import  './OraclePartidas.sol';

contract PartidaInteface {
    
   struct aposta {
        address payable carteiraApostador;
        uint idAposta;
        uint valorAposta;
        uint dataRegistro;
    }
    
    // Remete para o contrato de partidas e resultados
    OraclePartidas internal contratoPartidas;
    
    mapping(uint => aposta[]) public listaApostas;
    
    constructor (address _enderecoContrato){
        contratoPartidas =  OraclePartidas(_enderecoContrato);
        
    }
    
    function registrarAposta(uint _idPartida, uint _idAposta) public payable {
        
       // address payable enderecoCarteiraApostador = ; // apenas a carteira 
       // uint valorAposta = msg.value; // O valor de aposta do Participante
        
        // Cadastro a aposta
        aposta memory apostaNova;               // Criacao de nova aposta
        apostaNova.carteiraApostador        = payable(msg.sender);
        apostaNova.idAposta                 = _idAposta;
        apostaNova.valorAposta              = msg.value;
        apostaNova.dataRegistro             = block.timestamp;

        // REGISTRA A APOSTA
        listaApostas[_idPartida].push(apostaNova);
        
    }
    
    
    function listarApostas(uint _idPartida) public view returns (aposta[] memory){
        return listaApostas[_idPartida];
    }
    
    function valorTotalApostasPartida(uint _idPartida) public view returns (uint[] memory _valorApostasPartida){
        
        uint length = listaApostas[_idPartida].length;
        uint[] memory valorApostasPartida;

        for(uint i = 0; i < length; i++) {
            valorApostasPartida[listaApostas[_idPartida][i].idAposta] += listaApostas[_idPartida][i].valorAposta;
        } 
        return valorApostasPartida;
    }
    
    function valorTotalCustodia() public view returns(uint){
        return address(this).balance;
    }
    
    function valorTotalApostas() public view returns (uint[] memory _valorTotalApostas){
        
        // Pegar o total de Partidas no OraclePartidas
        uint totalPartidas = contratoPartidas.listarQuantidadePartidas();
        uint[] memory valorTotalApostas;
        
        for(uint idPartida = 0; idPartida < totalPartidas; idPartida++) {
            uint totalApostas = listaApostas[idPartida].length;
            
            for(uint numAposta = 0; numAposta < totalApostas; numAposta++) {
                valorTotalApostas[listaApostas[idPartida][numAposta].idAposta] += listaApostas[idPartida][numAposta].valorAposta;
            }
        }
        
        return valorTotalApostas;
        
    }
    
    
    
    /*function retornarPartida(uint _idPartida) public view returns (uint _idTimeVencedor, string memory _time1_Casa, string memory _time2_Visitante){
        uint idTimeVencedor;
        string memory time1_Casa;
        string memory time2_Visitante;
        
        // RECEBO AS VARIÁVEIS
        (idTimeVencedor, time1_Casa, time2_Visitante) = contratoPartidas.retornarPartida(_idPartida);
       
        return (idTimeVencedor, time1_Casa, time2_Visitante);
    }*/
    
    
}
