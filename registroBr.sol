/*SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Leandro Bissoli
This work is licensed under a Creative Commons Attribution 4.0 International License.
*/

pragma solidity >=0.7.0 <0.9.0; 

contract registroBr{
    
    ///struct Dominio{ < - vamos estudar isso - Criar objeto
    
    string private dominioNome; // Variável do nome de dominio
    string private titularId; // CPF ou CNPJ do Titular do nome do Domínio
    string private titularNome; // Nome do Titular do Nome de Domínio
    string private titularEmail; // Email do Titular do Nome de Domínio
    string private titularCep; // CEP do Titular do Nome de Domínio
    string private dominioDns_1; // DNS 1 do servidor
    string private dominioDns_2; // DNS 2 do servidor
    bool   private aceitaSaci; //  Aceita SACI-Adm (verdadeiro ou falso)
    uint   private prazoContrato; // Prazo de 1, 2, 3, 4 ou 5 anos
    uint[6] private valorPrazoContrato = [0, 40, 76, 112, 148, 184]; //valores por Prazo de Contrato 1, 2, 3, até 5 anos
    uint   private quantNotificacoes; // Quantidade de Notificações de Conflito de Nomes de Domínios

    string[3] private statusPagamentoLista  = ["0 - Aguardando Pagamento","1 - Pagamento Realizado","2 - Pagamento Atrasado"];
    uint private statusPagamento = 0;
    
    string[10] private dominioStatusLista = ["0 - Ativo", "1 - Inativo", "2 - Inativo - Falta Pagamento", "3 - Congelado", "4 - Suspenso", "5 - Expirado", "6 - Cancelado", "7 - Processo de Liberacao", "8 - Em Competicao", "9 - Liberado"];
    uint    private dominioStatus = 0;
 
    string[5] private dominioCanceladoMotivoLista = ["0 - nao aplicado", "1 - Falta de Pagamento", "2 - Dados Falsos", "3 - Falta de Documentos", "4 - Ordem Judicial"];
    uint private dominioCanceladoMotivo = 0;
    
    uint constant quantNotificacoesCongelarNomeDominio = 10;
    uint  quantPedidosPagamento = 0; // Até 3 pedidos para congelar o nome de dominio

     //Registro de Logs de Atividades
    event LogAlert(string description);
    
    // Registro de um novo contrato de nome de domínio
    constructor(string memory txtDominioNome, string memory txtTitularId, string memory txtTitularNome,
                string memory txtTitularEmail, string memory txtTitularCep, string memory txtDominioDns_1,
                string memory txtDominioDns_2, bool txtAceitaSaci, uint txtPrazoContrato)  {
        dominioNome = txtDominioNome; 
        titularId = txtTitularId;
        titularNome = txtTitularNome;
        titularEmail = txtTitularEmail;
        titularCep = txtTitularCep;
        dominioDns_1 = txtDominioDns_1;
        dominioDns_2 = txtDominioDns_2;
        aceitaSaci = txtAceitaSaci;
        prazoContrato = txtPrazoContrato;
        
        // Alterar o status do pagamento
        statusPagamento = 0; // Status Aguardando Pagamento
        // Alterar o status do nome de dominio
        dominioStatus = 2; // Falta o Pagamento
        
        emit LogAlert("Contrato Registrado");
    }
    
    // Confirmar Pagamento do Nome de Dominio
    function confirmaPagamentoNomeDominio() public returns (uint) {
        // Confirmar se o pagamento foi realizado para efetivação do registro Dominio
        if(statusPagamento == 0){
            statusPagamento = 1; // Status Pagamento Realizado
            dominioStatus = 0; // Dominio ativo
            quantPedidosPagamento = 0; // Pode pedir + 3 vezes o boleto
            emit LogAlert("Pagamento realizado com sucesso.");
            return valorPrazoContrato[prazoContrato];
        }
        else if(statusPagamento == 2){
            statusPagamento = 1; // Status Pagamento Realizado
            dominioStatus = 0; // Dominio ativo
            quantPedidosPagamento = 0; // Pode pedir + 3 vezes o boleto
            emit LogAlert("Pagamento realizado com sucesso.");
            return (valorPrazoContrato[prazoContrato] * 2); // Aplica 100% de multa
        }
        else{
            quantPedidosPagamento = 0; // Pode pedir + 3 vezes o boleto
            emit LogAlert("O seu Pagamento jah foi compensado.");
            return 0;
        }
    }
    
    // Emite Guia de Pagamento. Se emitir 3 vezes a Guia e não pagar Congela o nome de dominio
    function emiteCobrancaNomeDominio() public returns (string memory){
        if(quantPedidosPagamento < 3 && statusPagamento != 1){
            quantPedidosPagamento ++;
            return ("valor");
        }
        else if(quantPedidosPagamento == 3){
            dominioStatus = 3; // Dominio Congelado
            statusPagamento = 2; // Pagamento Atrasado
            return ("Dominio congelado");
        }
        else{
            return ("Pagamento em dia");
        }
    }
      
    // Cancela Nome de Domínio
    function cancelaNomeDominio(uint txtMotivo) private returns (bool) {
        if(dominioStatus != 6){
            dominioStatus = 6; // aplico o ID do Dominio Cancelado
            dominioCanceladoMotivo = txtMotivo;
            return true;
        }
        else{
            return false;
        }
       
       /*
       Se a pesquisa fosse texto
       if(keccak256(abi.encodePacked(dominioStatus)) != keccak256(abi.encodePacked("Cancelado"))){
            dominioStatus = "Cancelado";
            dominioCanceladoMotivo = txtMotivo;
            return true;
        }
      */
    } 
    
    // registra novo conflito. Notifica o Titular que um conflito foi aberto
    function notificaNovoConflitoNomeDominio() public returns (bool){
        quantNotificacoes ++;
        if(quantNotificacoes == quantNotificacoesCongelarNomeDominio){
            // dominio suspenso
            dominioStatus = 3; // ID status dominio congelado
        }
        emit LogAlert("Titular Notificado");
        return true;
    }
    
    function liberaNomeDominioCongelado() public returns (bool){
        quantNotificacoes = 0;
        dominioStatus = 0; //Id dominio ativo
        emit LogAlert("Nome de Dominio Ativado");
        return true;
    }
      
    
    //Transfere o Titular do Nome de Domínio
    function transfereTitular(string memory txtTitularId, string memory txtTitularNome, 
                              string memory txtTitularEmail, string memory txtTitularCep) public{
        titularId = txtTitularId;
        titularNome = txtTitularNome;
        titularEmail = txtTitularEmail;
        titularCep = txtTitularCep;
        emit LogAlert("Titular Alterado");
    }
    
    // Altera os dados de contato do Titular
    function alteraContatoTitular(string memory txtTitularEmail, string memory txtTitularCep) public{
        titularEmail = txtTitularEmail;
        titularCep = txtTitularCep;
        emit LogAlert("Contato Alterado");
    }
    
    // Retorna os dados do nome de dominio - Whois
    function pesquisaNomeDominio() public view returns (string memory){
        string memory teste;
        teste = string(abi.encodePacked(dominioNome, "/n",  verDadosTitular()));
        teste = string(abi.encodePacked(teste, "/nCEP: ", titularCep, " DNS 1: ", dominioDns_1, " DNS 2: ", dominioDns_2));
        teste = string(abi.encodePacked(teste, "/nAceita Saci", aceitaSaci));
        teste = string(abi.encodePacked(teste, "/nPrazo Contrato: ",  prazoContrato, " ano(s) /nValor do Contrato: R$ ", valorPrazoContrato[prazoContrato]));
        teste = string(abi.encodePacked(teste, "/nSituacao Pagamento: ", statusPagamentoLista[statusPagamento]));
        teste = string(abi.encodePacked(teste, "/nQuant. Notificacoes: ", quantNotificacoes));
        teste = string(abi.encodePacked(teste, "/nStatus Dominio: ", dominioStatusLista[dominioStatus]));
        teste = string(abi.encodePacked(teste, "/nCancelado: ", dominioCanceladoMotivoLista[dominioCanceladoMotivo]));
        teste = string(abi.encodePacked(teste, "/nQuantidade Pedidos Pagamento: ", quantPedidosPagamento));
        return teste;
        /*
        Isso aqui dá PAU! Stack Too Deep        
        return string(abi.encodePacked(dominioNome, "/n", titularNome," - (", titularId,") - <", titularEmail, 
                    ">/nCEP: ", titularCep, " DNS 1: ", dominioDns_1, " DNS 2: ", dominioDns_2, 
                    "/n Aceita Saci", aceitaSaci,
                    "/nPrazo Contrato: ",  prazoContrato, " ano(s) /nValor do Contrato: R$ ", valorPrazoContrato[prazoContrato],  
                    "/nSituacao Pagamento: ", statusPagamentoLista[statusPagamento], 
                    "/nQuant. Notificacoes: ", quantNotificacoes, 
                    "/nStatus Dominio: ", dominioStatusLista[dominioStatus], 
                    "/nCancelado: ", dominioCanceladoMotivoLista[dominioCanceladoMotivo], 
                    "/nQuantidade Pedidos Pagamento: ", quantPedidosPagamento));
        */
    }
    
    // Retorna os dados do Titular
    function verDadosTitular() public view returns (string memory) {
        return string(abi.encodePacked(titularNome," - (", titularId,") - <", titularEmail, ">"));
    }

    // visualiza a quantidade de notificações enviadas ao Titular
    function verQuantConflitoNomeDominio() public view returns (uint){
        return quantNotificacoes;
    }
    
    //Verificar Pagamento
    function verSituacaoPagamento() public view returns (string memory){
        return statusPagamentoLista[statusPagamento];
    }
    
    /*
    function abreProcessoCompetitivoNomeDominio(){
        // Caso o nome de dominio esteja com status "PROCESSO DE LIBERACAO"
        // Pode entrar em processo competitivo 
        // caso exista mais de um interessado no nome de dominio, inicia o lance
        //quando 2 ou mais candidatos sao constatadados (2 tickets para o mesmo nome de dominio)
        // Prazo de 30 min para entrar novos candidatos
        // apos este periodo abre o prazo para os lances
        // lances minimos = 50,00; limite de 2 min para novos lances
    }
    
    function informaResultadoProcessoCompetitivo(){
        // apos o processo competitivo apresenta o nome do novo titular
    }
    */

}
