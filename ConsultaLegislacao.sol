/*SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Leandro Bissoli
This work is licensed under a Creative Commons Attribution 4.0 International License.
*/

pragma solidity >=0.7.0 <0.9.0; 

contract ConsultaLegislacao{
     // Trabalhando com variável tipo mapping
    mapping (int => string[]) private anoPublicacao;
    // Cada chave é um ANO 
    // Cada ANO teremos um ARRAY de Leis
  
    constructor(){
        // Estruturando o mapa. IMPORTANTE: Dificuldade pois não existe a possibilidade de loop
        anoPublicacao[2001] = ["lei 1/2001", "lei 2/2001", "lei 3/2001", "lei 4/2001", "lei 5/2001"];
        anoPublicacao[2002] = ["lei 6/2002", "lei 7/2002", "lei 8/2002"];
        anoPublicacao[2010] = ["lei 9/2010", "lei 10/2010"];
        anoPublicacao[2020] = ["lei 11/2020", "lei 12/2020", "lei 13/2020", "lei 14/2020"];
        anoPublicacao[2021] = ["lei 15/2021"];
        anoPublicacao[2022] = new string[](0);
    }
 
    function incluirAnoPublicacao (int _anoPublicacao) public {
        anoPublicacao[_anoPublicacao] = new string[](0);
        
    }
    
    function incluirLeiPublicada (int _anoPublicacao, string memory _lei) public {
        anoPublicacao[_anoPublicacao].push(_lei);
        
    }
    
    function retornarQuantidadeLeisAno (int _anoPublicacao) public view returns (uint) {
        // Retorna o tamanho do Array (leis) dentro do Mapping (Ano) = Quantidade de Leis
        return anoPublicacao[_anoPublicacao].length;
    }
    
    function listarLeisAno (int _anoPublicacao) public view returns (string[] memory) {
       // Lista todas as Leis de um ANO
       return anoPublicacao[_anoPublicacao];
    }
    
    function limparAno (int _anoPublicacao) public {
       // Limpa todas as Leis de um ANO    
       anoPublicacao[_anoPublicacao] = new string[](0);
    }
 
    function retornarLei (int _anoPublicacao, uint _idLei) public view returns (string memory){
       //retorna uma lei especifica
       // Tratando o erro ID da LEI maior que o Array
       if(anoPublicacao[_anoPublicacao].length > _idLei){
            return anoPublicacao[_anoPublicacao][_idLei];   
       }
       else{
           return "lei nao encontrada";
        }
    }

    function deletarLei (int _anoPublicacao, uint _idLei) public {
      // A ideia é repopular o Array sem a lei excluída
      // O objetivo é ter esta posição limpa e o ARRAY reorganizado novamente
      // anoPublicacao[_anoPublicacao][_idLei] = "";
      
      // Tratando o erro ID da LEI maior que o Array
      if(anoPublicacao[_anoPublicacao].length > _idLei){
            for (uint i = _idLei; i < anoPublicacao[_anoPublicacao].length -1; i++){
                anoPublicacao[_anoPublicacao][i] = anoPublicacao[_anoPublicacao][i+1];
            }
            anoPublicacao[_anoPublicacao].pop(); // retiro o ultimo array que ficou repetido
        }
    }
}
