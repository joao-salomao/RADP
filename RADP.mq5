//+------------------------------------------------------------------+
//|                                                         RADP.mq5 |
//|                                                     João Salomão |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "João Salomão"
#property link      "https://www.mql5.com"
#property version   "1.00"

// Includes
#include "OptionScanner.mqh"

// Classes
OptionScanner optionScanner();

// Indicators handles
int handle_hpf;


bool test = false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handle_hpf = iCustom(_Symbol,_Period, "MEUS\\RoboHarmonico", 100);
   //handle_hpf = iCustom(_Symbol,_Period,"HarmonicPatternFinder v3/HarmonicPatternFinderV3");
   //optionScanner.ShowActiveOptions();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   
   
  }
//+------------------------------------------------------------------+
