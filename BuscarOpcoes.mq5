//+------------------------------------------------------------------+
//|                                                 BuscarOpcoes.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#property description "Essse Script tem por objetivo buscar informações de opções."

#include<Strings/String.mqh>
CString tratarString;

// tipos de mercado (BMF e Bovespa) e os ativos de cada categoria
string BMF = "BMF";
string BOVESPA_A_VISTA = "BOVESPA\A VISTA";
string BOVESPA_INDICES = "BOVESPA\INDICES";
string BOVESPA_OPCOES = "BOVESPA\OPCOES";
string BOVESPA_FRACIONARIO = "BOVESPA\FRACIONARIO";

string nomeOpcaoMaiorVol = "";
double maiorVol = -1;

// flags para filtrar as opções de uma empresa específica
// caso desejar exibir todas isFiltrar=false
bool isFiltrar = true;
string filtro = "ITUB";


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
//---

   Print("Iniciando...");
   
   long inicioExec = GetMicrosecondCount();
   
   // invoca função para detectar os ativos (opções) e seus respectivos preços   
   detectarAtivosPrecos();
   
   long fimExec = GetMicrosecondCount();
   
   Print("Tempo de execução: " + (fimExec - inicioExec)/1000 + " ms" );
   
}
//+------------------------------------------------------------------+  

//+----------------------------------------------------------------------+
//| Método que detecta os ativos (opções) e os seus repectivos precos.   |
//+----------------------------------------------------------------------+
void detectarAtivosPrecos( ){
        
   uint todosAtivos = SymbolsTotal(false);
   //Print("TODOS: ", todosAtivos );
      
   int TOTAL_BMF = 0;
   int TOTAL_BOVESPA_A_VISTA = 0;
   int TOTAL_BOVESPA_INDICES = 0;
   int TOTAL_BOVESPA_OPCOES = 0;
   int TOTAL_BOVESPA_FRACIONARIO = 0;
   
   string nomeAtivo = "";
   string caminho = "";
   
   // laço que buscará todos os ativos listado na bolsa - B3
   int k = 1;
   for(int i=0; i < todosAtivos; i++){

      nomeAtivo = SymbolName(i, false);
      Print(nomeAtivo);
      caminho = SymbolInfoString(nomeAtivo, SYMBOL_PATH);
      
      // filtro específico para OPÇÕES
      if( StringFind(caminho, BOVESPA_OPCOES) > -1  ){
         
         // será filtrado por uma opção ou exibirá todas?
         if( !isFiltrar || ( isFiltrar && StringFind(nomeAtivo, filtro) > -1 )  ) {
            
            // coloca o simbolo no janela Observação do Mercado (CTRL + M)
            if( !SymbolSelect(nomeAtivo, true) ){
               SymbolSelect(nomeAtivo, true);
            }
            
            // aguarda um tempo para que a opção apareca na janela Observação do Mercado
            // senão não é possível ler os dados (e.g., preço, volume, ....)
            Sleep(100);
                
            // exibe as informações da opção
            obterInfoOpcao( nomeAtivo );
            
            // remove o simbolo no janela Observação do Mercado (senão ficaria com milhares!!)
            SymbolSelect(nomeAtivo, false);
                      
            TOTAL_BOVESPA_OPCOES++;
            
            k++;
                        
         }
      }
      
   } // fim for
   
   Print("\nOpção com maior volume de negociação: " + nomeOpcaoMaiorVol + " - Vol: ", maiorVol);
   Print("\nTotal Ações com opções: ", TOTAL_BOVESPA_OPCOES  );
   
   // ABRE O GRÁFICO DA OPÇÃO COM MAIOR VOLUME NEGOCIADO
   ChartOpen(nomeOpcaoMaiorVol, PERIOD_D1);
   
}


//+------------------------------------------------------------------+
//| Método  voltado para obter das opções.                           |
//+------------------------------------------------------------------+
void obterInfoOpcao( string nomeAtivo ){
            
      double precoUltimoNegocio = SymbolInfoDouble(nomeAtivo, SYMBOL_LAST);
      double bid = SymbolInfoDouble(nomeAtivo, SYMBOL_BID);
      double ask = SymbolInfoDouble(nomeAtivo, SYMBOL_ASK);
      datetime dataHoraUltimoNegocio = (datetime)SymbolInfoInteger(nomeAtivo, SYMBOL_TIME);
      // as opções tem data limite para negociação antes de virarem pó
      datetime dataFimNegociacaoOpcao = (datetime)SymbolInfoInteger(nomeAtivo, SYMBOL_EXPIRATION_TIME); 
      double volumeTotalDia = SymbolInfoDouble(nomeAtivo, SYMBOL_SESSION_VOLUME);
      
      string descricao = SymbolInfoString(nomeAtivo, SYMBOL_DESCRIPTION);
      string nomeAcao = SymbolInfoString(nomeAtivo, SYMBOL_BASIS);
      
      // FILTROS: mostrar apenas aquelas que está tendo negociação, com volume e com expiração no mês corrente        
      if( bid != 0 && ask != 0 && precoUltimoNegocio != 0 && volumeTotalDia != 0  && compararDatasIgualOuMaiorMesAno(TimeCurrent(), dataHoraUltimoNegocio)  && compararDatasIgualOuMaiorMesAno(TimeCurrent(), dataFimNegociacaoOpcao) ){
         
         // exibe
         Print(nomeAtivo, ": ", DoubleToString(precoUltimoNegocio, 2), " - ", volumeTotalDia, " - ", detectarPutCall(nomeAtivo), " - Valor de strike: ", obterStrike( descricao ), " - ", TimeToString(dataFimNegociacaoOpcao, TIME_DATE), " - ", nomeAcao  ); 
            
         // para saber qual a opção com maior volulme de negociação
         if( volumeTotalDia > maiorVol ){
            maiorVol = volumeTotalDia;
            nomeOpcaoMaiorVol = nomeAtivo;
         } 
     
      }     
}

//+---------------------------------------------------------------------------------------+
//| Método que compara duas datas se são maiores ou iguais em consideração o mês e o ano. |
//+---------------------------------------------------------------------------------------+
bool compararDatasIgualOuMaiorMesAno( datetime data1, datetime data2 ){
   
   MqlDateTime dataEstrutura1;
   TimeToStruct(data1, dataEstrutura1);
   
   MqlDateTime dataEstrutura2;
   TimeToStruct(data2, dataEstrutura2);
   
   if( dataEstrutura2.mon >= dataEstrutura1.mon && dataEstrutura2.year >= dataEstrutura1.year  ){
      return true;
   }
   
   return false;
   
}

//+------------------------------------------------------------------------+
//| Método que compara duas data levando em consideração o mês, ano e dia. |
//+------------------------------------------------------------------------+
bool compararDatasMesAnoDia( datetime data1, datetime data2 ){
   
   MqlDateTime dataEstrutura1;
   TimeToStruct(data1, dataEstrutura1);
   
   MqlDateTime dataEstrutura2;
   TimeToStruct(data2, dataEstrutura2);
   
   if( dataEstrutura1.day == dataEstrutura2.day && dataEstrutura1.mon == dataEstrutura2.mon && dataEstrutura1.year == dataEstrutura2.year ){
      return true;
   }
   
   return false;
   
}


//+------------------------------------------------------------------+
//| Método para detectar se é PUT ou CALL.                           |
//+------------------------------------------------------------------+
string detectarPutCall(string nomeOpcao){
  
  // nome das opçoes: NNNNSV
  string serieOpcao = StringSubstr(nomeOpcao, 4, 1);
  
  if( serieOpcao == "A" || serieOpcao == "B" || serieOpcao == "C" || serieOpcao == "D" 
     || serieOpcao == "E" || serieOpcao == "F" || serieOpcao == "G" || serieOpcao == "H"
     || serieOpcao == "I" || serieOpcao == "J" || serieOpcao == "K" || serieOpcao == "L"
    ){
    
    return "CALL";
  
  }
  
  return "PUT";
   
}

//+------------------------------------------------------------------+
//| Método para detectar o strike da opção.                          |
//+------------------------------------------------------------------+
double obterStrike(string descricao){
   
   string partes[];
   
   // Substitui o espaço por ; Ex.: ABEV     ON     17.98 para ABEVON17.98
   tratarString.Assign( descricao );
   tratarString.Replace( " ", ";" );
   tratarString.Remove( ";;" );
   
   // string atualizada
   descricao = tratarString.Str();
    
   ushort codSep = StringGetCharacter(";", 0); 
   
   if( StringSplit(descricao, codSep, partes ) > 0 ){
      
      // a última parte onde está o preço
      string valor = partes[ ArraySize(partes) - 1];
      
      // tira a vírgula para ponto
      StringReplace(valor, ",", ".");  
      
      // retira os espaços em branco
      StringTrimLeft(valor);
      StringTrimRight(valor);
      
      return StringToDouble(valor);
            
   }
      
   return 0;
   
}
