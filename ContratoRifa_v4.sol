/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Leandro Bissoli na aula do Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
Projeto para criar um smart contract para execução de RIFAS.
*/

pragma solidity >=0.7.0 <0.9.0;

contract ContratoRifa{

    // Estruturar a Rifa
    struct Rifa { // Funciona como um objeto
        string  nomeRifa; // nome da rifa
        address payable enderecoCarteiraRifa; // endereço da casa
        address payable[] numeroParticipante; // Versão Alternativa
        uint quantNumerosRifa; // total de números da Rifa
        uint quantNumerosDisponiveis; // total de números disponíveis para venda - vai reduzindo conforme a venda
        uint valorNumero; // valor de cada número
        uint porcentagemAdminRifa; // valor que fica para casa da RIFA - Faturamento
        bool ativaRifa; // se a rifa está ativo ou já foi fechada
        address payable participanteGanhador; // participante ganhador da Rifa 
    }

    Rifa[] private Rifas; // Lista de todas as Rifas. Mais interessante que um mapping
    address public admin; // Está publico para nao perder o controle do Admin e testar o modifier
    
    event novaRifa(address _adminAddress, uint _idRifa, uint _quantNumerosDisponiveis);
    event fecharRifa(address _adminAddress, uint _idRifa, uint _quantNumerosVendidos);
    event ganhadorRifa(uint _idRifa, address _ganhadorAddress, uint _valorPremio);
    event pagarRifa(uint _idRifa, string _mensagem);
    
    constructor () {
        admin = msg.sender; // Gravo o Admin deste Contrato
    }
    
    // MODIF
    //Estabelecer uma caracteristtica para funcoes
    modifier somenteAdmin { 
        // Somente quem registrou o contrato possui este perfil. Esta no constructor. ADMIN
        require(msg.sender == admin, "Somente o Administrador do Contrato pode executar estea funcao");
        _;
    }
    
    // Funcao para Criar uma nova RIFA
    function criarRifa(string memory _nomeRifa, address payable _enderecoCarteiraRifa, uint _quantNumeros, uint _valorNumero, uint _porcentagemAdminRifa) public payable somenteAdmin { //<- Modificador aqui

        Rifa memory rifaNova;               // Criacao do Objeto RIFA
        rifaNova.nomeRifa                   = _nomeRifa;
        rifaNova.enderecoCarteiraRifa       = _enderecoCarteiraRifa;
        rifaNova.numeroParticipante         =  new address payable[](0);// o primeiro número é zero e nao consta no sorteio da Rifa
        rifaNova.quantNumerosRifa           = _quantNumeros;
        rifaNova.quantNumerosDisponiveis    = _quantNumeros;
        rifaNova.valorNumero                = _valorNumero;
        rifaNova.porcentagemAdminRifa       = _porcentagemAdminRifa;
        rifaNova.ativaRifa                  = true;
        
        //Acrescento na Lista de Rifas do Contrato
        Rifas.push(rifaNova);
        
        // GERA EVENTO DE UMA RIFA NOVA
        emit novaRifa(rifaNova.enderecoCarteiraRifa, Rifas.length, rifaNova.quantNumerosRifa);
    }
    
    // Funcao de apoio para listar RIFAS
    function listarRifas() public view returns (Rifa[] memory){
        return Rifas;
    }
    
    // Funcao para o Participante COMPRAR números da RIFA. Apenas com o valor. Pode ter troco.
    function comprarNumerosRifa(uint _idRifa, address payable _enderecoCarteiraParticipante) public payable returns (uint _quantNumerosComprados, uint _troco){
        
        require((Rifas.length > _idRifa), "ESTA RIFA NAO EXISTE."); // Se nao existe Rifa com este ID
        require(Rifas[_idRifa].ativaRifa, "RIFA ENCERRADA"); // Exigencia = RIFA está ativa?
        require(Rifas[_idRifa].quantNumerosDisponiveis > 0, "TODOS NUMEROS VENDIDOS"); // Exigencia = TEM números disponíveis
        

        address payable enderecoCarteiraParticipante = _enderecoCarteiraParticipante; // apenas a carteira 
        uint valorPedido = msg.value; // O valor entregue pelo Participante
        
        
        // Calculo do total de numeros da Rifa
        uint quantNumerosPedido = valorPedido / Rifas[_idRifa].valorNumero;
        
        // Chama a funcao de selecao de números e devolve o total de números quantNumerosComprados
        uint quantNumerosComprados = selecionarNumerosRifa(_idRifa, enderecoCarteiraParticipante, quantNumerosPedido);
        
        // Verifica se tem TROCO
        uint troco = valorPedido - (quantNumerosComprados * Rifas[_idRifa].valorNumero);
        
        //Devolver para Carteira do Cliente
        if(troco > 0) { // tem troco
           enderecoCarteiraParticipante.transfer(troco);
        }
        
        return (quantNumerosComprados, troco);
    }
    
    function selecionarNumerosRifa(uint _idRifa, address payable _participanteComprador, uint _quantNumerosPedido) private returns (uint _quantNumerosComprados){
        // NAO precisa de REQUIRE pois ela eh chamada dentro da comprarNumerosRifa
        
        uint quantNumerosPedido = _quantNumerosPedido;
        uint quantNumerosComprados = 0;

        for (uint i = 1; i <= quantNumerosPedido; i++){
            
            if(Rifas[_idRifa].quantNumerosDisponiveis > 0){ // tem número livre na rifa
                quantNumerosComprados = quantNumerosComprados + 1; // Efetivo a compra do numero para Participante
                Rifas[_idRifa].numeroParticipante.push(_participanteComprador); // Coloco o Participante na lista de PArticipantes
                Rifas[_idRifa].quantNumerosDisponiveis = Rifas[_idRifa].quantNumerosDisponiveis - 1; // Reduzo um numero da Rifa de disponibilidade
            }
            else{
                // Acabou os numeros da Rifa
                // Fecha a Rifa
                finalizarRifa(_participanteComprador, _idRifa);
                break; // sai do loop
            }
        }
        return quantNumerosComprados;
      
    }
    
    function finalizarRifa(address _participanteComprador, uint _idRifa) private { // chamando quando o ultimo numero é comprado.

        // Fechando a Rifa
        Rifas[_idRifa].ativaRifa = false;
        
        emit fecharRifa( _participanteComprador, _idRifa, Rifas[_idRifa].quantNumerosRifa); // COMPLETOU A QUANTIDADE DE NUMEROS VENDIDOS
    }
    
    function finalizarRifaAdmin(uint _idRifa) public somenteAdmin {//<- Modificador aqui. A Rifa pode ser encerrada pelo Admin antes do término
        
        require((Rifas.length > _idRifa), "ESTA RIFA NAO EXISTE.");//require Se a Rifa existe
        
        require(Rifas[_idRifa].ativaRifa, "RIFA JA FOI ENCERRADA"); // A Rifa já foi encerrada antes
        
        // Fechando a Rifa
        Rifas[_idRifa].ativaRifa = false;
        
        emit fecharRifa(msg.sender, _idRifa, Rifas[_idRifa].numeroParticipante.length); // ENCERROU A RIFA mas pode ter numeros disponíveis
    }
    
    function gerarGanhadorRifa(uint _idRifa) public somenteAdmin{
        require(!Rifas[_idRifa].ativaRifa, "RIFA NAO FOI ENCERRADA"); // Exigencia = RIFA está ativa?     
        require(Rifas[_idRifa].participanteGanhador != Rifas[_idRifa].numeroParticipante[0], "A APURACAO JAH ACONTECEU.");
        
        // Busco o Ganhador
        uint numeroGanhador = gerarNumeroAleatorio (_idRifa,Rifas[_idRifa].numeroParticipante.length);
        
        address payable ganhadorParticipante = Rifas[_idRifa].numeroParticipante[numeroGanhador];

        // Registra o ganhador na rifa
        Rifas[_idRifa].participanteGanhador = ganhadorParticipante;
         
        uint valorTotalRifa = (Rifas[_idRifa].numeroParticipante.length * Rifas[_idRifa].valorNumero); // Valor total obtido na venda dos numeros
        
        uint valorPremio = (valorTotalRifa * (100 - Rifas[_idRifa].porcentagemAdminRifa))/100; // O valor da Premiacao para Participante ganhador
        
        uint valorAdminRifa = (valorTotalRifa * (Rifas[_idRifa].porcentagemAdminRifa))/100; // O valor da Premiacao para o Admin da Rifa
        
        // Gerar o evento de ganhador
        emit ganhadorRifa(_idRifa, ganhadorParticipante, valorPremio);
               
        // Chamar o REPASSSE dos VALORES
        fazerPagamentosRifa(_idRifa, valorPremio, valorAdminRifa);

    
    }
    
    function visualizarGanhador(uint _idRifa) public view returns(address _participanteGanhador){
        //require Se a Rifa existe
        require((Rifas.length > _idRifa), "ESTA RIFA NAO EXISTE.");
        // require se a Rifa foi encerrada
        require(!Rifas[_idRifa].ativaRifa, "A RIFA CONTINUA ATIVA.");
        // require se o ganhador já foi sorteado
        require(Rifas[_idRifa].participanteGanhador == Rifas[_idRifa].numeroParticipante[0], "A APURACAO AINDA NAO ACONTECEU.");
        
        return Rifas[_idRifa].participanteGanhador;
        
    }
    
    function fazerPagamentosRifa(uint _idRifa, uint _valorPremio, uint _valorAdminRifa) private somenteAdmin {
        // Aqui vamos passar os valores da RIFA para o PARTICIPANTE GANHADOR e o ADMIN do Contrato
        
         Rifas[_idRifa].participanteGanhador.transfer(_valorPremio); // Vai para Carteira do Participante Ganhador
         
         Rifas[_idRifa].enderecoCarteiraRifa.transfer(_valorAdminRifa); // Vai para Carteira do Admin da RIFA
         
         emit pagarRifa (_idRifa, "transferencias realizadas");
         
    }
    
    // Funcao para gerar um numero aleatorio com base em um id dinamico e o numero máximo de numeros da rifa
    function gerarNumeroAleatorio(uint _idRifa, uint _valorMaximo) private view returns (uint) {

        uint numeroAleatorio = uint(keccak256(abi.encodePacked(_idRifa, block.timestamp, block.difficulty, msg.sender))) % _valorMaximo;
        
        numeroAleatorio = numeroAleatorio + 1; // Para tirar o "zero" e ter a possibilidade de chegar no máximo
        
        return numeroAleatorio;

    }
    
    function valoresContrato() public view returns(uint){
        return address(this).balance;
    }
   
}
