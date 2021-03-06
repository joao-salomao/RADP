//+------------------------------------------------------------------+
//|                                                RoboHarmonico.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

#include <Trade/OrderInfo.mqh>
COrderInfo ordensPendentes;

#include <ChartObjects\ChartObjectsArrows.mqh>
CChartObjectArrow topo, icone;


#include <ChartObjects\ChartObjectsLines.mqh>
CChartObjectTrend linhaTrend;

#include <ChartObjects\ChartObjectsFigures.mqh>
CChartObjectTriangle triangulo;

CAccountInfo infoConta;
CTrade trade;
CSymbolInfo ativoInfo;

int idRobo = 190531;

#resource "\\Indicators\\fastzz.ex5";

double zzTopoBuffer[];
double zzFundoBuffer[];
datetime tempoCandleBuffer[];
int zzHandle;
int input totalCopiarBuffer = 100;

double precoTopoAtual;
double precoTopoAnt;
datetime dataTopoAtual;
datetime dataTopoAnt;

double precoFundoAtual;
double precoFundoAnt;
datetime dataFundoAtual;
datetime dataFundoAnt;

double precoFundoAntPen;
datetime dataFundoAntPen;

input int desvio = 20;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

   zzHandle = iCustom(_Symbol, _Period, "::Indicators\\fastzz.ex5", desvio );

   if(zzHandle == INVALID_HANDLE) {
      Print("Falha ao criar o indicador ZigZag: ", GetLastError());
      return(INIT_FAILED);
   }

   // define para acessar como timeseries
   ArraySetAsSeries(zzTopoBuffer, true);
   ArraySetAsSeries(zzFundoBuffer, true);
   ArraySetAsSeries(tempoCandleBuffer, true);

   // ativo
   ativoInfo.Name( _Symbol );


   return(INIT_SUCCEEDED);

}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   IndicatorRelease(zzHandle);

   //ObjectDelete(0);
}

int totalBarrasAnt = 0;

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {


   // copia os topos
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, tempoCandleBuffer) < 0 )  {
      Print("Erro ao copiar tempos: ", GetLastError());
      return;
   }


   // copia os topos
   if(CopyBuffer(zzHandle, 0, 0, totalCopiarBuffer, zzTopoBuffer) < 0 )  {
      Print("Erro ao copiar dados dos topos: ", GetLastError());
      return;
   }

   int tamVet = ArraySize ( zzTopoBuffer );
   int nrTopo = 0;
   for( int i = 0; i < tamVet; i++  ) {

      if( zzTopoBuffer[i] != 0 ) {
         if( nrTopo == 0 ) {
            dataTopoAtual = tempoCandleBuffer[i];
            precoTopoAtual = zzTopoBuffer[i];

         } else if( nrTopo == 1 ) {
            dataTopoAnt = tempoCandleBuffer[i];
            precoTopoAnt = zzTopoBuffer[i];

            criarIcone("topoAnt", precoTopoAnt, dataTopoAnt, clrBlue, 38);
            criarIcone("topoAtual", precoTopoAtual, dataTopoAtual, clrLightBlue, 38);

            removerIcone("linhaTopo");
            criarLinhaTendencia("linhaTopo", dataTopoAnt, precoTopoAnt, dataTopoAtual, precoTopoAtual, clrPurple, STYLE_DASH, 1, true, false);

            break;
         }
         nrTopo++;
      }

   } // fim for topo para obter apenas os dois últimos topos mais atuais


   // copia os fundos
   if(CopyBuffer(zzHandle, 1, 0, totalCopiarBuffer, zzFundoBuffer) < 0 )  {
      Print("Erro ao copiar dados dos fundos: ", GetLastError());
      return;
   }

   tamVet = ArraySize ( zzFundoBuffer );
   int nrFundo = 0;
   for( int i = 0; i < tamVet; i++  ) {

      if( zzFundoBuffer[i] != 0 ) {
         if( nrFundo == 0 ) {
            dataFundoAtual = tempoCandleBuffer[i];
            precoFundoAtual = zzFundoBuffer[i];

         } else if( nrFundo == 1 ) {
            dataFundoAnt = tempoCandleBuffer[i];
            precoFundoAnt = zzFundoBuffer[i];


         } else if( nrFundo == 2 ) {
            dataFundoAntPen = tempoCandleBuffer[i];
            precoFundoAntPen = zzFundoBuffer[i];

            removerIcone("linhaFundo");
            criarLinhaTendencia("linhaFundo", dataFundoAntPen, precoFundoAntPen, dataFundoAtual, precoFundoAtual, clrOrange, STYLE_DASH, 1, true, false);

            bool isResult = calcularGartleyBullish(precoFundoAntPen, precoTopoAnt, precoFundoAnt, precoTopoAtual, precoFundoAtual);

            if( isResult ) {
               //XA
               criarLinhaTendencia("XA" + dataFundoAntPen, dataFundoAntPen, precoFundoAntPen, dataTopoAnt, precoTopoAnt, clrDarkGreen, STYLE_SOLID, 3, false, false);
               criarLinhaTendencia("AB" + dataTopoAnt, dataTopoAnt, precoTopoAnt, dataFundoAnt, precoFundoAnt, clrDarkGreen, STYLE_SOLID, 3, false, false);
               criarLinhaTendencia("BC" + dataFundoAnt, dataFundoAnt, precoFundoAnt, dataTopoAtual, precoTopoAtual, clrDarkGreen, STYLE_SOLID, 3, false, false);
               criarLinhaTendencia("CD" + dataTopoAtual, dataTopoAtual, precoTopoAtual, dataFundoAtual, precoFundoAtual, clrDarkGreen, STYLE_SOLID, 3, false, false);

               //criarLinhaTendencia("A-C", dataTopoAnt, precoTopoAnt, dataTopoAtual, precoTopoAtual, clrDarkGreen, STYLE_DOT, 1, false, false);
               //criarLinhaTendencia("A-C", dataTopoAnt, precoTopoAnt, dataTopoAtual, precoTopoAtual, clrDarkGreen, STYLE_DOT, 1, false, false);
               //criarLinhaTendencia("X-D", dataFundoAntPen, precoFundoAntPen, dataFundoAtual, precoFundoAtual, clrDarkGreen, STYLE_DOT, 1, false, false);

               criarTriangulo("T-XAC" + dataFundoAntPen, dataFundoAntPen, precoFundoAntPen, dataTopoAnt, precoTopoAnt, dataFundoAnt, precoFundoAnt,  clrLightGreen, STYLE_SOLID, 1, false, false);
               criarTriangulo("T-BCD" + dataFundoAnt, dataFundoAnt, precoFundoAnt, dataTopoAtual, precoTopoAtual, dataFundoAtual, precoFundoAtual,  clrLightGreen, STYLE_SOLID, 1, false, false);

               // COMPRA
               ativoInfo.Refresh(); // atualiza os dados do ativo
               double vol = ativoInfo.LotsMin();
               double stop = precoFundoAntPen;
               double takeProfit = precoTopoAtual;

               bool isOrdemCompraAberta = buscarPosicaoAbertasByTipo( POSITION_TYPE_BUY );

               // abrirá apenas uma ordem de compra por vez
               if( !isOrdemCompraAberta ) {
                  abrirOrdem(ORDER_TYPE_BUY, ativoInfo.Ask(), vol, stop, takeProfit, "GB");
               }

            }

            break;
         }
         nrFundo++;
      }

   } // fim for fundo para obter apenas os dois últimos fundos mais atuais

}


//---------------------------------------------------------------------------------
// Método para calcular/detectar Gartley Bullish
//---------------------------------------------------------------------------------
bool calcularGartleyBullish( double X, double A, double B, double C, double D) {

   X = NormalizeDouble( X, _Digits) ;
   B = NormalizeDouble( B, _Digits) ;
   C = NormalizeDouble( C, _Digits) ;
   D = NormalizeDouble( D, _Digits) ;

   double AB1 = NormalizeDouble( (A - X) * 0.618, _Digits) ;
   double AB2 = NormalizeDouble( (A - X) * 0.5, _Digits);

   if(  B >= (A - AB1) && B <= ( A - AB2)  ) {
      // Print("XABLAU... B");

      double BC1 = NormalizeDouble(  ( A - B ) * 0.618, _Digits) ;
      double BC2 = NormalizeDouble( ( A - B ) * 0.886, _Digits) ;

      if(  C >= (B + BC1) && C <= (B + BC2) ) {
         Print("XABLAU... C");

         double XA1 = NormalizeDouble(  (A - X) * 0.986, _Digits) ;
         double XA2 = NormalizeDouble(  (A - X) * 0.786, _Digits) ;

         /*
         Print("XA1: ", (A - XA1) );
         Print("XA2: ", (A - XA2) );
         Print("D: ", D);
         Print("X: ", X);
         */

         if( D >= (A - XA1) && D <= (A - XA2)  ) {
            Print("GARTLEYYYYYYYYYYYY BULL!! ");
            return true;
            //criarIcone("GARTLEY", precoTopoAnt, dataTopoAnt, clrBlue, 38);
         }
      }

   }

   return false;

}

//---------------------------------------------------------------------------------
// Método para um desenho de fractal nos topos e fundos.
//---------------------------------------------------------------------------------
void criarIcone(string nome, double preco, datetime tempo, color cor, char codigoSimbolo) {

// https://www.mql5.com/en/docs/constants/objectconstants/wingdings
//char codigoSimbolo = 244;
   int tam = 1;

   icone.Create(0, nome, 0, tempo, preco, codigoSimbolo);

   icone.Color(cor);
   icone.Fill(true);
   icone.Width(tam);
   //icone.Background(true);

}


// ---------------------------------------------------------------------
// Método responsável por remover o icone de todo do gráfico pelo nome
// ---------------------------------------------------------------------
void removerIcone(string nome) {

// remove
   ObjectDelete(0, nome);

// Print("REMOVER: ", nome);
   ChartRedraw();

}



//---------------------------------------------------------------------------------
// Método para desenhar linha de tendência
//---------------------------------------------------------------------------------
void criarTriangulo(string nome, datetime t1, double p1, datetime t2, double p2,  datetime t3, double p3, color cor, ENUM_LINE_STYLE estilo = STYLE_SOLID, int largura = 1, bool isRaioDireita = false, bool isRaioEsquerda = false) {

   triangulo.Create(0, nome, 0, t1, p1, t2, p2, t3, p3);
   triangulo.Color(cor);
   triangulo.Style(estilo);
   triangulo.Fill(true);
   triangulo.Width(largura);

}


//---------------------------------------------------------------------------------
// Método para desenhar linha de tendência
//---------------------------------------------------------------------------------
void criarLinhaTendencia(string nomeLinha, datetime t1, double p1, datetime t2, double p2, color cor, ENUM_LINE_STYLE estilo = STYLE_SOLID, int largura = 1, bool isRaioDireita = false, bool isRaioEsquerda = false) {

   linhaTrend.Create(0, nomeLinha, 0, t1, p1, t2, p2);
   linhaTrend.Color(cor);
   linhaTrend.Style(estilo);
   linhaTrend.RayLeft(isRaioEsquerda);
   linhaTrend.RayRight(isRaioDireita);
   linhaTrend.Width(largura);


}

//-----------------------------------------------------------------------------------+
// Função responsável por abrir uma operação                                         |
//-----------------------------------------------------------------------------------+
void abrirOrdem(ENUM_ORDER_TYPE tipoOrdem, double preco, double volume, double sl = 0, double tp = 0, string coment = "") {

   bool result;
   preco = NormalizeDouble(preco, _Digits);
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);

   // seta o identificador do robô
   trade.SetExpertMagicNumber(idRobo);
   trade.SetTypeFillingBySymbol(_Symbol);

   if(tipoOrdem == ORDER_TYPE_BUY) {

      result = trade.Buy(volume, _Symbol, preco, sl, tp, coment);

   } else if (tipoOrdem == ORDER_TYPE_SELL) {

      result = trade.Sell(volume, _Symbol, preco, sl, tp, coment);

   } else if(tipoOrdem == ORDER_TYPE_BUY_LIMIT) {

      result = trade.BuyLimit(volume, preco, _Symbol, sl, tp, ORDER_TIME_GTC, 0, coment);

   } else if(tipoOrdem == ORDER_TYPE_SELL_LIMIT) {

      result = trade.SellLimit(volume, preco, _Symbol, sl, tp, ORDER_TIME_GTC, 0, coment);

   }

   // problema na requisição
   if(!result) {
      Print("Não foi possível abrir uma ordem de " + EnumToString(tipoOrdem), ". Código: ", trade.ResultRetcode() );
   }

}

//+-------------------------------------------------------------+
// Função responsável por fechar uma ordem/posição no mercado   |
//+-------------------------------------------------------------+
void fecharTodasPosicoesRobo() {

   double saldo = 0;
   int totalPosicoes = PositionsTotal();

   for(int i = 0; i < totalPosicoes; i++) {

      string simbolo = PositionGetSymbol(i);
      ulong  magic = PositionGetInteger(POSITION_MAGIC);

      if( simbolo == _Symbol && magic == idRobo ) {

         saldo = PositionGetDouble(POSITION_PROFIT);

         // fecha e verifica
         if(!trade.PositionClose(PositionGetTicket(i))) {
            Print("Erro ao fechar a negociação. Código: ", trade.ResultRetcode() );
         } else {
            Print("Saldo: ", saldo);
         }
      }
   }
}


//----------------------------------------------------------------------+
//                                                                      |
// Função responsável por verificar se há posições abertas por tipo     |
//                                                                      |
//----------------------------------------------------------------------+
bool buscarPosicaoAbertasByTipo(ENUM_POSITION_TYPE tipoPosicaoBusca) {

   int totalPosicoes = PositionsTotal();
   //Alert("POSICOES ABERTAS: " + totalPosicoes + " - Tipo posicao busca: " + EnumToString(tipoPosicaoBusca) );
   double lucroPosicao;

   for(int i = 0; i < totalPosicoes; i++) {

      // obtém o nome do símbolo a qual a posição foi aberta
      string simbolo = PositionGetSymbol(i);

      if(simbolo != "") {

         // id do robô
         ulong  magic = PositionGetInteger(POSITION_MAGIC);
         lucroPosicao = PositionGetDouble(POSITION_PROFIT);
         ENUM_POSITION_TYPE tipoPosicaoAberta = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
         // obtém o simbolo da posição
         string simboloPosicao = PositionGetString(POSITION_SYMBOL);

         // se é o robô e ativo em questão
         if(magic == idRobo && simboloPosicao == _Symbol) {

            // caso operação
            if(tipoPosicaoBusca == tipoPosicaoAberta) {

               //Alert("RETORNO POSICAO ABERTA: " + EnumToString(tipoPosicaoAberta) + " - ROBO: " + magic);
               //Alert("TEM VENDA");
               return true;
            }
         } // fim magic

      } else {
         PrintFormat("Erro quando recebeu a posição do cache com o indice %d." + " Error code: %d", i, GetLastError());
         ResetLastError();
      }

   } // fim for

   return false;

}

//----------------------------------------------------------------------+
// Método responsável por obter o histórico de negociação                                                       |
//----------------------------------------------------------------------+
void obterHistoricoNegociacaoRobo() {

   HistorySelect(0, TimeCurrent());
   uint     total = HistoryDealsTotal();
   ulong    ticket = 0;
   double   price, profit;
   datetime time;
   string   symbol;
   long     type, entry;

   for(uint i = 0; i < total; i++) {

      if((ticket = HistoryDealGetTicket(i)) > 0) {
         price = HistoryDealGetDouble(ticket, DEAL_PRICE);
         time  = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         type  = HistoryDealGetInteger(ticket, DEAL_TYPE);
         entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
         profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         int magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
         string coment = HistoryDealGetString(ticket, DEAL_COMMENT);

         if( entry == DEAL_ENTRY_OUT && symbol == _Symbol && magic == idRobo  ) {

            Print("Ativo: ", symbol, " - Preço saída: ", price, " - Lucro: ", profit, " - Entry: ", entry  );
         }
      }
   }

}

//----------------------------------------------------------------------+
// Método responsável por excluir todas as ordens pendentes             |
//----------------------------------------------------------------------+
bool excluirTodasOrdensPendentesRobo( ) {

   bool isOk = true;

   // pecorre todas a ordens pendentes abertas
   for(int i = OrdersTotal() - 1 ; i >= 0; i--) {

      // seleciona a ordem pendente por seu índice
      if( ordensPendentes.SelectByIndex(i) ) {

         // se a ordem pedente for do ativo monitorado e aberta pelo robô
         if(ordensPendentes.Symbol() == _Symbol  && ordensPendentes.Magic() == idRobo)
            if (!trade.OrderDelete( ordensPendentes.Ticket() ) ) {
               Print("Erro ao excluir a ordem pendente ", ordensPendentes.Ticket(), ". Erro: ", GetLastError() );
            }
      }
   }

   return isOk;
}


//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void gravarArquivo() {

   // PATH\\MQL5\\Files
   string nomeArquivo = "dadosCandle.csv";
   int fileHandle = FileOpen(nomeArquivo, FILE_READ | FILE_WRITE | FILE_CSV);

   if( fileHandle != INVALID_HANDLE ) {
   
      // copianos os candles e GRAVANDO
      MqlRates candles[];
      int totalCandles = CopyRates(_Symbol, _Period, 0, 100, candles);

      if( totalCandles > 0 ) {
         for(int i = 0; i < totalCandles; i++) {
            MqlRates cand = candles[i];
            string dadoGravar = cand.time + ";" + cand.open + ";" + cand.close;
            FileWrite(fileHandle,  dadoGravar); // escreve no buffer

            if( i == totalCandles - 1 ) {
               FileFlush(fileHandle); // grava no arquivo
            }
         }
         FileClose(fileHandle); // fecha o arquivo
      }
   }
}
//+------------------------------------------------------------------+
