/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
*/
pragma solidity 0.8.4;

contract Leilao {

    struct Ofertante { // Funciona como um objeto
        string nome;
        address payable enderecoCarteira;
        uint oferta;
        bool jaFoiReembolsado;
    }
    
    address payable public contaGovernamental;
    uint public prazoFinalLeilao;

    address public maiorOfertante;
    uint public maiorLance;

    mapping(address => Ofertante) public listaOfertantes; // A chave é o endereço da carteira e temos o Objeto "Ofertante" armazenado
    Ofertante[] public ofertantes;

    bool public encerrado;

    event novoMaiorLance(address ofertante, uint valor); // Cria um Evento e o que aparecer nele. Vaia aparecer na aba eventos do etherscan
    event fimDoLeilao(address arrematante, uint valor); // Cria um Evento e o que aparecer nele. Vaia aparecer na aba eventos do etherscan

    modifier somenteGoverno { // estabelece uma caracteristica da funcao
        require(msg.sender == contaGovernamental, "Somente Governo pode realizar essa operacao");
        _; // Se o requerimento for satisfeito, ele segue..
    }

    constructor(
        uint _duracaoLeilao,
        address payable _contaGovernamental
    ) {
        contaGovernamental = _contaGovernamental;
        prazoFinalLeilao = block.timestamp + _duracaoLeilao; // Número em Segundos
    }


    function lance(string memory nomeOfertante, address payable enderecoCarteiraOfertante) public payable { // Pagável - Funcao que movimenta carteira
        require(block.timestamp <= prazoFinalLeilao, "Leilao encerrado."); // Condições para execuçao do contrato. Se atendido, segue o processamento. Não tem custo.
        require(msg.value > maiorLance, "Ja foram apresentados lances maiores.");
        
        maiorOfertante = msg.sender;
        maiorLance = msg.value;
        
        //Realizo estorno das ofertas aos perdedores
        /*
        For é composto por 3 parametros (separados por ponto virgula)
            1o  é o inicializador do indice
            2o  é a condição que será checada para saber se o continua 
                o loop ou não 
            3o  é o incrementador (ou decrementador) do indice
        */
        
        for (uint i=0; i<ofertantes.length; i++) {
            Ofertante storage ofertantePerdedor = ofertantes[i]; // esta gravado no BlkChain
            if (!ofertantePerdedor.jaFoiReembolsado) {
                ofertantePerdedor.enderecoCarteira.transfer(ofertantePerdedor.oferta); /// É a açao para transferir dinheiro
                ofertantePerdedor.jaFoiReembolsado = true;
            }
        }
        
        //Crio o ofertante
        Ofertante memory ofertanteVencedorTemporario = Ofertante(nomeOfertante, enderecoCarteiraOfertante, msg.value, false);
        
        //Adiciono o novo concorrente vencedor temporario no array de ofertantes
        ofertantes.push(ofertanteVencedorTemporario);
        
        //Adiciono o novo concorrente vencedor temporario na lista (mapa) de ofertantes
        listaOfertantes[ofertanteVencedorTemporario.enderecoCarteira] = ofertanteVencedorTemporario;
    
        emit novoMaiorLance (msg.sender, msg.value); // Registrando o event da transação
    }
    
    /* REFERENCIA GIRAO
    //Crio o ofertante
    Ofertante memory ofertanteVencedorTemporario = Ofertante(nomeOfertante, enderecoCarteiraOfertante, msg.value, false);
    if (ofertantes.length = 0){
        // está sendo apresentada a primeira proposta, logo não precisa reembolsar ninguem
    }
    else{
        // existem propostas anteriores, mas todas, com exceção da última já foram reembolsadas
        // até porque a proposta só é aceita se for maior que a anterior (i.e., a última é a de maior valor antes da atual)
        // precisa reembolsar o último
        ofertantes[ofertantes.length-1].enderecoCarteira.transfer(ofertantes[ofertantes.length-1].oferta);
        ofertantes[ofertantes.length-1].jaFoiReembolsado = true;
    }
    ofertantes.push(ofertanteVencedorTemporario);
*/

    function finalizaLeilao() public somenteGoverno { // somente após passar pelo modificador o processamente segue
       
        require(block.timestamp >= prazoFinalLeilao, "Leilao ainda nao encerrado.");
        //   !encerrado é uma expressão mais curta para checar se a condição é falsa
        //   é o mesmo que escrever encerrado == false 
        require(!encerrado, "Leilao encerrado.");

        encerrado = true;
        emit fimDoLeilao(maiorOfertante, maiorLance); // Registrando o event da transação

        contaGovernamental.transfer(address(this).balance);// todo o saldo desde contrato vai para conta do Governo
    }
}
