//+------------------------------------------------------------------+
//|                                             HarmonicPatterns.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\Internal\CompareFunction.mqh>

#define PATTERNS_COUNT 14
#define FOUR_POINTERS_PATTERNS_COUNT 2
#define FIVE_POINTERS_PATTERNS_COUNT 12

enum PATTERN_INDEX {
   BULLISH_GARTLEY=0,
   BEARISH_GARTLEY,
   BULLISH_ABCD,
   BEARISH_ABCD,
   BULLISH_BUTTERFLY,
   BEARISH_BUTTERFLY,
   BULLISH_BAT,
   BEARISH_BAT,
   BULLISH_CRAB,
   BEARISH_CRAB,
   BULLISH_DEEP_CRAB,
   BEARISH_DEEP_CRAB,
   BULLISH_SHARK,
   BEARISH_SHARK,
};

PATTERN_INDEX FIVE_POINTERS_PATTERNS[FIVE_POINTERS_PATTERNS_COUNT] = {
   BULLISH_GARTLEY,
   BEARISH_GARTLEY,
   BULLISH_BUTTERFLY,
   BEARISH_BUTTERFLY,
   BULLISH_BAT,
   BEARISH_BAT,
   BULLISH_CRAB,
   BEARISH_CRAB,
   BULLISH_DEEP_CRAB,
   BEARISH_DEEP_CRAB,
   BULLISH_SHARK,
   BEARISH_SHARK,
};

PATTERN_INDEX FOUR_POINTERS_PATTERNS[FOUR_POINTERS_PATTERNS_COUNT] = {
   BULLISH_ABCD,
   BEARISH_ABCD
};

struct PATTERN_DESCRIPTOR {
   PATTERN_INDEX     index;
   double            XAMin;
   double            XAMax;
   double            ABMin;
   double            ABMax;
   double            BCMin;
   double            BCMax;
   double            XADMin;
   double            XADMax;
};

struct PATTERN_INSTANCE {
   PATTERN_INDEX     index;
   PATTERN_DESCRIPTOR patternDescriptor;
   bool              isBullish;
   bool              isFourPoints;
   datetime          XDateTime;
   datetime          ADateTime;
   datetime          BDateTime;
   datetime          CDateTime;
   datetime          DDateTime;
   double            X;
   double            A;
   double            B;
   double            C;
   double            D;
};



class HarmonicPatterns {
private:
   PATTERN_INSTANCE        patternsInstances[];
   void                    AddPatternDescriptorToArray( PATTERN_DESCRIPTOR &patternDescriptor );
   void                    PopulatePatternsDescriptors( void );
   bool                    VerifyFibonnaciRatio( double high, double low, double value, double highRatio, double lowRatio );
   bool                    HarmonicPatterns::DatetimeComparitionFourPointsPatterns( PATTERN_INSTANCE &pattern );
   bool                    HarmonicPatterns::DatetimeComparitionFivePointsPatterns( PATTERN_INSTANCE &pattern );
   bool                    CalculateBullishFivePointsPattern( PATTERN_INSTANCE &pattern );
   bool                    CalculateBearishFivePointsPattern( PATTERN_INSTANCE &pattern );
   bool                    CalculateBullishFourPointsPattern( PATTERN_INSTANCE &pattern );
   bool                    CalculateBearishFourPointsPattern( PATTERN_INSTANCE &pattern );

public:
   PATTERN_DESCRIPTOR      patternsDescriptors[PATTERNS_COUNT];
                           HarmonicPatterns();
                           ~HarmonicPatterns();
   bool                    CalculateHarmonicPattern( PATTERN_INSTANCE &pattern );
};

//+-----------------------------------------------------------------------------+
//| Construtor: Chama o método que preenche o array com os Patterns Descriptors |
//+-----------------------------------------------------------------------------+
HarmonicPatterns::HarmonicPatterns() {
   PopulatePatternsDescriptors();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HarmonicPatterns::~HarmonicPatterns() {
   ArrayFree( patternsInstances );
}

//+------------------------------------------------------------------+
//| Chama o método correto para calcular o Padrão Harmônico          |
//+------------------------------------------------------------------+
bool HarmonicPatterns::CalculateHarmonicPattern( PATTERN_INSTANCE &pattern ) {
   bool result;

   if ( pattern.isBullish ) {

      if ( pattern.isFourPoints ) {

         result = CalculateBullishFourPointsPattern( pattern );

      } else {

         result = CalculateBullishFivePointsPattern( pattern );

      }

   } else {

      if ( pattern.isFourPoints ) {

         result = CalculateBearishFourPointsPattern( pattern );

      } else {

         result = CalculateBullishFivePointsPattern( pattern );

      }

   }

   return result;
}


//+-------------------------------------------------------------+
//| Método genérico para detectar os Padrões Harmônicos Bullish |
//| com cinco pontos gráficos.                                  |
//+-------------------------------------------------------------+
bool HarmonicPatterns::CalculateBullishFivePointsPattern( PATTERN_INSTANCE &pattern ) {
   double X, A, B, C, D;

   X =  pattern.X;
   A =  pattern.A;
   B =  pattern.B;
   C =  pattern.C;
   D =  pattern.D;

   return (
             VerifyFibonnaciRatio( A, X, B, pattern.patternDescriptor.XAMax, pattern.patternDescriptor.XAMin ) &&
             VerifyFibonnaciRatio( A, B, C, pattern.patternDescriptor.ABMax, pattern.patternDescriptor.ABMin ) &&
             VerifyFibonnaciRatio( C, B, D, pattern.patternDescriptor.BCMax, pattern.patternDescriptor.BCMin ) &&
             VerifyFibonnaciRatio( A, X, D, pattern.patternDescriptor.XADMax, pattern.patternDescriptor.XADMin )
          );
}

//+-------------------------------------------------------------+
//| Método genérico para detectar os Padrões Harmônicos Bearish |
//| com cinco pontos gráficos.                                  |
//+-------------------------------------------------------------+
bool HarmonicPatterns::CalculateBearishFivePointsPattern( PATTERN_INSTANCE &pattern ) {
   double X, A, B, C, D;

   X =  pattern.X;
   A =  pattern.A;
   B =  pattern.B;
   C =  pattern.C;
   D =  pattern.D;

   return (
             VerifyFibonnaciRatio( X, A, B, pattern.patternDescriptor.XAMax, pattern.patternDescriptor.XAMin ) &&
             VerifyFibonnaciRatio( B, A, C, pattern.patternDescriptor.ABMax, pattern.patternDescriptor.ABMin ) &&
             VerifyFibonnaciRatio( B, C, D, pattern.patternDescriptor.BCMax, pattern.patternDescriptor.BCMin ) &&
             VerifyFibonnaciRatio( X, A, D, pattern.patternDescriptor.XADMax, pattern.patternDescriptor.XADMin )
          );

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HarmonicPatterns::CalculateBullishFourPointsPattern( PATTERN_INSTANCE &pattern ) {
   double A, B, C, D;

   A =  pattern.A;
   B =  pattern.B;
   C =  pattern.C;
   D =  pattern.D;


   return (
             VerifyFibonnaciRatio( A, B, C, pattern.patternDescriptor.ABMax, pattern.patternDescriptor.ABMin ) &&
             VerifyFibonnaciRatio( C, B, D, pattern.patternDescriptor.BCMax, pattern.patternDescriptor.BCMin )
          );
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HarmonicPatterns::CalculateBearishFourPointsPattern( PATTERN_INSTANCE &pattern ) {
   double A, B, C, D;

   A =  pattern.A;
   B =  pattern.B;
   C =  pattern.C;
   D =  pattern.D;


   return (
             VerifyFibonnaciRatio( B, A, C, pattern.patternDescriptor.ABMax, pattern.patternDescriptor.ABMin ) &&
             VerifyFibonnaciRatio( B, C, D, pattern.patternDescriptor.BCMax, pattern.patternDescriptor.BCMin )
          );
}

//+---------------------------------------------------------------------+
//| Verifica se o valor passado está dentro das ratios de fibo passadas |
//+---------------------------------------------------------------------+
bool HarmonicPatterns::VerifyFibonnaciRatio( double high, double low, double value, double highRatio, double lowRatio ) {
   double numerator =  MathAbs( ( high - value ) );
   double denominator =  MathAbs( ( high - low ) );

   if ( numerator == 0 || denominator == 0 ) return false;

   double ratio = numerator / denominator;

   return ( ratio >= lowRatio ) && ( ratio <= highRatio );
}


/*
   https://www.mql5.com/pt/docs/standardlibrary/generic/compare

   int Compare(
      const datetime  x,     // primeiro valor
      const datetime  y      // segundo valor
   );

   Valor de retorno

   Retorna o número que expressa a razão entre os dois valores comparados:

   resultado inferior a zero – x é menor que y (x<y)
   resultado igual a zero – x igual a y (x=y)
   resultado superior a zero – x maior que y (x>y)
*/

//+-----------------------------------------------------------------+
//|  Compara os DateTimes dos padrões que possuem 4 pontos seguem a |
//|  uma sequência cronológica.                                     |
//+-----------------------------------------------------------------+
bool HarmonicPatterns::DatetimeComparitionFourPointsPatterns( PATTERN_INSTANCE &pattern ) {
   datetime A, B, C, D;
   
   A = pattern.ADateTime;
   B = pattern.BDateTime;
   C = pattern.CDateTime;
   D = pattern.DDateTime;
   
   return (
             Compare(B, A) > 0
             && Compare(C, B) > 0
             && Compare(D, C) > 0
          );
}

//+------------------------------------------------------------------+
//|  Compara os DateTimes dos padrões que possuem 5 pontos seguem a |
//|  uma sequência cronológica.                                     |
//+------------------------------------------------------------------+
bool HarmonicPatterns::DatetimeComparitionFivePointsPatterns( PATTERN_INSTANCE &pattern ) {
   datetime X, A, B, C, D;
   
   X = pattern.XDateTime;
   A = pattern.ADateTime;
   B = pattern.BDateTime;
   C = pattern.CDateTime;
   D = pattern.DDateTime;

   return (
             Compare(A, X) > 0
             && Compare(B, A) > 0
             && Compare(C, B) > 0
             && Compare(D, C) > 0
          );
}

//+----------------------------------------------------------------+
//| Adiciona um PATTERN_DESCRIPTOR no  array patternsDescriptors   |                                                     |
//+----------------------------------------------------------------+
void HarmonicPatterns::AddPatternDescriptorToArray(PATTERN_DESCRIPTOR &patternDescriptor) {
   patternsDescriptors[patternDescriptor.index] = patternDescriptor;
}



//+--------------------------------------------------------------------+
//| Popula o array com os PATTERNS_DESCRIPTOR de cada Padrão Harmônico |                                                               |
//+--------------------------------------------------------------------+
void HarmonicPatterns::PopulatePatternsDescriptors() {
   PATTERN_DESCRIPTOR bullishGartley = { BULLISH_GARTLEY, 0.5, 0.618, 0.618, 0.786, 1.27, 1.618, 0.7, 0.786 };
   PATTERN_DESCRIPTOR bearishGartley = { BEARISH_GARTLEY, 0.5, 0.618, 0.618, 0.786, 1.27, 1.618, 0.7, 0.786 };
   PATTERN_DESCRIPTOR bullishABCD = { BULLISH_ABCD, 0, 0, 0.618, 0.786, 1.27, 1.618, 0, 0 };
   PATTERN_DESCRIPTOR bearishABCD = { BEARISH_ABCD, 0, 0, 0.618, 0.786, 1.27, 1.618, 0, 0 };
   PATTERN_DESCRIPTOR bullishButterfly = { BULLISH_BUTTERFLY, 0.7, 0.786, 0.618, 0.786, 1.5, 1.618, 1.27, 1.618 };
   PATTERN_DESCRIPTOR bearishButterfly = { BEARISH_BUTTERFLY, 0.7, 0.786, 0.618, 0.786, 1.5, 1.618, 1.27, 1.618 };
   PATTERN_DESCRIPTOR bullishBat = { BULLISH_BAT, .382, .5, .382, .886, 1.618, 2.618, .8, .886 };
   PATTERN_DESCRIPTOR bearishBat = { BULLISH_BAT, .382, .5, .382, .886, 1.618, 2.618, .8, .886 };
   PATTERN_DESCRIPTOR bullishCrab = { BULLISH_CRAB, .382, .618, .382, .886, 2.618, 3.618, 1.5, 1.618 };
   PATTERN_DESCRIPTOR bearishCrab = { BEARISH_CRAB, .382, .618, .382, .886, 2.618, 3.618, 1.5, 1.618 };
   PATTERN_DESCRIPTOR bullishDeepCrab = { BULLISH_DEEP_CRAB, .8, .886, .382, .886, 2, 3.618, 1.5, 1.618 };
   PATTERN_DESCRIPTOR bearishDeepCrab = { BEARISH_DEEP_CRAB, .8, .886, .382, .886, 2, 3.618, 1.5, 1.618 };
   PATTERN_DESCRIPTOR bullishShark = { BULLISH_SHARK, .886, 1.13, 1.13, 1.618, 1.618, 2.24 };
   PATTERN_DESCRIPTOR bearishShark = { BEARISH_SHARK, .886, 1.13, 1.13, 1.618, 1.618, 2.24 };

   AddPatternDescriptorToArray(bullishGartley);
   AddPatternDescriptorToArray(bearishGartley);
   AddPatternDescriptorToArray(bullishABCD);
   AddPatternDescriptorToArray(bearishABCD);
   AddPatternDescriptorToArray(bullishButterfly);
   AddPatternDescriptorToArray(bearishButterfly);
   AddPatternDescriptorToArray(bullishBat);
   AddPatternDescriptorToArray(bearishBat);
   AddPatternDescriptorToArray(bullishCrab);
   AddPatternDescriptorToArray(bearishCrab);
   AddPatternDescriptorToArray(bullishDeepCrab);
   AddPatternDescriptorToArray(bearishDeepCrab);
   AddPatternDescriptorToArray(bullishShark);
   AddPatternDescriptorToArray(bearishShark);
}
//+------------------------------------------------------------------+
