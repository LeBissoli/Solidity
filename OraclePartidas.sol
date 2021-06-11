/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Leandro Bissoli na aula do Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
Projeto para criar um smart contract que funciona como listagem de partidas e acompanhamento de seus resultados (ORACLE de Partidas)
*/

pragma solidity >=0.7.0 <0.9.0;

contract OraclePartidas{
    
    struct partida{
        uint dataRegistro;
        string time1_Casa;
        string time2_Visitante;
        uint timeVencedor;
        bool resultadoAtualizado;
    }
    
    partida[] private Partidas;
    
    
    address public admin; // Está publico para nao perder o controle do Admin e testar o modifier
    
    event novaPartidaLog(string time1_Casa, string time2_Visitante);
    event novoResultadoLog(uint _idPartida, uint _timeVencedor);

    // MODIF
    //Estabelecer uma caracteristtica para funcoes
    modifier somenteAdmin { 
        // Somente quem registrou o contrato possui este perfil. Esta no constructor. ADMIN
        require(msg.sender == admin, "Somente o Administrador do Contrato pode executar estea funcao");
        _;
    }
    
    constructor () {
        admin = msg.sender; // Gravo o Admin deste Contrato
    }
    
    // Funcao de apoio para listar as partidas registradas no Oracle
    function listarPartidas() public view returns (partida[] memory){
        return Partidas;
    }
    
    function retornarVencedor(uint _idPartida) public view returns (uint _idTime){
        require(Partidas[_idPartida].resultadoAtualizado, "AGUARDANDO RESULTADO"); // Exigencia = O jogo deve ter o resultado publicado
        
        return Partidas[_idPartida].timeVencedor;
    }
    
    function cadastrarNovaPartida(string memory _time1_Casa, string memory _time2_Visitante) somenteAdmin public returns (bool){
        
        partida memory partidaNova;          // Criaçao de uma nova partida
        partidaNova.time1_Casa                  = _time1_Casa;
        partidaNova.time2_Visitante             = _time2_Visitante;
        partidaNova.timeVencedor                = 0;
        partidaNova.resultadoAtualizado         = false;
        partidaNova.dataRegistro                = block.timestamp;

        //Acrescento na Lista de Partidas
        Partidas.push(partidaNova);
        
        // GERA EVENTO DE UMA PARTIDA NOVA PARA COMECAR AS APOSTAS
        emit novaPartidaLog(partidaNova.time1_Casa, partidaNova.time2_Visitante);
        return true;
        
    }
    
    function registrarVencedor(uint _idPartida, uint _timeVencedor) somenteAdmin public returns (bool){
       
        Partidas[_idPartida].timeVencedor = _timeVencedor;
        Partidas[_idPartida].resultadoAtualizado = true;
        
        // GERA EVENTO DO RESULTADO DO JOGO
        emit novoResultadoLog(_idPartida, Partidas[_idPartida].timeVencedor);
        return true;
    }
    
}
