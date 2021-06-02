/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Leandro Bissoli na aula do Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
Projeto para criar um smart contract para execução de promoções comerciais.
*/

pragma solidity >=0.7.0 <0.9.0;

contract ContratoRifa{

    // Estruturar a Rifa
    struct Rifa { // Funciona como um objeto
        string nomeRifa; // nome da rifa
        address payable enderecoCarteiraRifa; // endereço da casa
        address payable[] numeroParticipante; // Versão Alternativa
        uint quantNumerosDisponiveis; // total de números 
        uint valorNumero; // valor de cada número
        uint porcentagemRifa; // valor que fica para casa da RIFA - Faturamento
        bool ativaRifa; // se a rifa está ativo ou já foi fechada
        address payable participanteGanhador; // participante ganhador da Rifa 
    }

    Rifa[] private Rifas; // Lista de todas as Rifas
    address admin;
    
    // EVENTOS NovaRifa, FimRifa, Ganhador
    
    constructor () {
        admin = msg.sender;
    }
    

    function criarRifa(string memory _nomeRifa, address payable _enderecoCarteiraRifa, uint _quantNumeros, uint _valorNumero, uint _porcentagemRifa) public payable {
        // require admin
        
        Rifa memory rifaNova;
        rifaNova.nomeRifa = _nomeRifa;
        rifaNova.enderecoCarteiraRifa = _enderecoCarteiraRifa;
        rifaNova.numeroParticipante =  new address payable[](_quantNumeros);       
        rifaNova.quantNumerosDisponiveis = _quantNumeros;
        rifaNova.valorNumero = _valorNumero;
        rifaNova.porcentagemRifa = _porcentagemRifa;
        rifaNova.ativaRifa = true;
        
        //Acrescento na Lista de Rifas do Contrato
        Rifas.push(rifaNova);
   }
  
    function listaRifas() public view returns (Rifa[] memory){
        return Rifas;
    }
    
    function comprarNumerosRifa(uint _idRifa, address payable _enderecoCarteiraParticipante) public payable returns (uint _quantNumerosComprados, uint _troco){
        //require(); Colocar condição se a RIFA está ativa bem como TEM números disponíveis
        

        address payable enderecoCarteiraParticipante = _enderecoCarteiraParticipante; // apenas a carteira 
        uint valorCompra = msg.value; // O valor entregue pelo Participante
        
        // Calculo do total de numeros da Rifa
        
        uint quantNumerosParticipante = valorCompra / Rifas[_idRifa].valorNumero;
        
        // Chama a funcao de selecao de números e devolve o total de números quantNumerosComprados
        uint quantNumerosComprados = selecionaNumerosRifa(_idRifa, enderecoCarteiraParticipante, quantNumerosParticipante);
        
        // Simulando o retorno
        //uint quantNumerosComprados = 2;
        uint troco = valorCompra - (quantNumerosComprados * Rifas[_idRifa].valorNumero);
        
        
        //Devolver para Carteira do Cliente
        if(troco > 0) { // tem troco
           enderecoCarteiraParticipante.transfer(troco);
        }
        
        return (quantNumerosComprados, troco);
    }
    
    function selecionaNumerosRifa(uint _idRifa, address payable _participanteComprador, uint quantNumerosParticipante) private returns (uint _quantNumerosComprados){
        // require (); // Condição se existe algum número disponível

        uint quantNumerosComprados = 0;

        for (uint i = 0; i < quantNumerosParticipante; i++){
            if(Rifas[_idRifa].quantNumerosDisponiveis > 0){ // tem número livre na rifa
                quantNumerosComprados = quantNumerosComprados + 1;
                
                /// registrar posiçao do Participante na Rifa
                for (uint a = 0; a < Rifas[_idRifa].numeroParticipante.length; a++){
                    if(!verificaEndereco(Rifas[_idRifa].numeroParticipante[a])){ // Verifico se existe algum endereco neste número. Se tem, o número está ocupado
                        Rifas[_idRifa].numeroParticipante[a] = _participanteComprador;
                        break;
                    }
                }
                ////////
                
                Rifas[_idRifa].quantNumerosDisponiveis = Rifas[_idRifa].quantNumerosDisponiveis - 1; // Reduzo um numero da Rifa
            }
        }
        return quantNumerosComprados;
        
    }
    
    
    function finalizaRifa(uint _idRifa) public{
        Rifas[_idRifa].ativaRifa = false;
    }
    
    function ganhadorRifa(uint _idRifa) public{
        // require Se ela ainda está aberta E Se ela não tem um Ganhador
        uint numeroGanhador = 1;
        
        address payable ganhadorParticipante = Rifas[_idRifa].numeroParticipante[numeroGanhador];
        Rifas[_idRifa].participanteGanhador = ganhadorParticipante;
    
    }
    
    function visualizaParticipanteGanhador(uint _idRifa) public view returns(address _participanteGanhador){
        //require
        return Rifas[_idRifa].participanteGanhador;
        
    }
    
    function verificaEndereco(address _endereco) private view returns(bool){
      uint32 size;
      address a = _endereco;
      assembly {
        size := extcodesize(a)
      }
      return (size > 0);
    }
    
}
