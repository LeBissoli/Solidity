
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
    uint   private prazoContrato; // Prazo de 1, 2 ou 5 anos
    
    
    uint   private quantNotificacoes; // Quantidade de Notificações de Conflito de Nomes de Domínios

    
    string[3] private statusPagamentoLista  = ["0 - Aguardando Pagamento","1 - Pagamento Realizado","2 - Pagamento Atrasado"];
    uint private statusPagamento;
    
    string private dominioStatus;
        // status: Ativo (sem pendências); Inativo (falta 1 DNS); Aguardando pagamento (falta primeiro pagamento);
        // status: Congelado (falta novo pagamento); 
        // status: Suspenso (muita notificaçao de fraude); 
        // status: Expirado (passou a fase de congelado);
        // Cancelado (Titular ou Comitê Gestor Cancelou); 
        // status: Processo de Liberacao (disponibiliza para novos Titulares, após 1hr de estar:inativo, falta de pagamento, congelado ou cancelado)
        // status: Em Competicao (tickets e lances em andamento)
        // status: Liberado - passou o processo de liberacao - 2hrs
        
    
    string[4] private dominioCanceladoMotivoLista = ["0 - Falta de Pagamento", "1 - Dados Falsos", "2 - Falta de Documentos", "3 - Ordem Judicial"];
    uint private dominioCanceladoMotivo;
    
    uint constant quantNotificacoesCongelarNomeDominio = 10;
    
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
        statusPagamento = 0;
        
        emit LogAlert("Contrato Registrado");
    }
    
    //Mudar nome do Titular
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
    
    // retorna os dados do Titular
    function informaTitular() public view returns (string memory) {
        return string(abi.encodePacked(titularNome," - (", titularId,") - <", titularEmail, ">"));
    }
    
    function confirmaPagamentoNomeDominio() public returns (bool) {
        // Confirmar se o pagamento foi realizado para efetivação do registro Dominio
        statusPagamento = 1;
        return true;
    }
    
    // Retorna os dados do Titular do Nome de Domínio
    function pesquisaNomeDominio() public view returns (string memory){
    // retorna os dados do titular e do nome de dominio
    // Titular, Documento, DNS, SACI, Data Criado, Data Expirado, Dada Alterado, Status Nome Domínio
    
    }
    
    // Cancela Nome de Domínio
    function cancelaNomeDominio(uint txtMotivo) private returns (bool) {
        if(keccak256(abi.encodePacked(dominioStatus)) != keccak256(abi.encodePacked("Cancelado"))){
            dominioStatus = "Cancelado";
            dominioCanceladoMotivo = txtMotivo;
            return true;
        }
        else{
            return false;
        }
    }
    
    // registra novo conflito. Notifica o Titular que um conflito foi aberto
    function notificaNovoConflitoNomeDominio() public returns (bool){
        quantNotificacoes ++;
        if(quantNotificacoes == quantNotificacoesCongelarNomeDominio){
            // dominio suspenso
            dominioStatus = "Suspenso";
        }
        emit LogAlert("Titular Notificado");
        return true;
    }
    
    function liberaNomeDominioCongelado() public returns (bool){
        quantNotificacoes = 0;
        dominioStatus = "Liberado";
        emit LogAlert("Nome de Dominio Liberado");
        return true;
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
    
    function emiteCobrancaNomeDominio(){
        // emite a guia de Pagamento
        // Informa meio de pagamento
        // limitada até 3 emissoes sem pagar
        // depois congela
    }*/
}
