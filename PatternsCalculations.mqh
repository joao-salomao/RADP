//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "PatternsDescriptions.mqh"

//-------------------------------------------------
// Método para calcular/detectar Gartley Bullish  |
//-------------------------------------------------
bool CalculateBullishGartley(PATTERN_INSTANCE &pattern) {
   double X,A,B,C,D;

   X = pattern.X;
   A = pattern.A;
   B = pattern.B;
   C = pattern.C;
   D = pattern.D;

   double AB1 = (A - X) * 0.618;
   double AB2 = (A - X) * 0.5;

   if(B >= (A - AB1) && B <= (A - AB2)) {

      double BC1 = (A - B) * 0.618;
      double BC2 = (A - B) * 0.886;

      if(C >= (B + BC1) && C <= (B + BC2)) {

         double XA1 = (A - X) * 0.986;
         double XA2 = (A - X) * 0.786;
         if(D >= (A - XA1) && D <= (A - XA2)) {
            return true;
         }
      }

   }

   return false;

}


//+-------------------------------------------------+
//| Método para calcular/detectar Gartley Bullish   |
//+-------------------------------------------------+
bool CalculateBearishGartley(PATTERN_INSTANCE &pattern) {
   double X, A, B, C, D, XAMin, XAMax, ABMin, ABMax, BCMin, BCMax;

   X = pattern.X;
   A = pattern.A;
   B = pattern.B;
   C = pattern.C;
   D = pattern.D;

   XAMin = X - ((X - A) * .7);
   XAMax = X - ((X - A) * .618);

   if(B >= XAMin && B <= XAMax) {


      ABMin = B - ((B - A) * 0.786);
      ABMax = B - ((B - A) * 0.618);

      if(C >= ABMin && C <= ABMax) {

         BCMin = B + ((B - C) * 1.27);
         BCMax =  B + ((B - C) * 1.618);

         if(D >= BCMin && D <= BCMax) {

            return true;

         }

      }

   }

   return false;
}

//+--------------------------------+
//| Calcula o Padrão Bullish ABCD  |
//+--------------------------------+
bool CalculateBullishABCD( PATTERN_INSTANCE &pattern ) {
   double A, B, C, D, ABMin, ABMax, CDMin, CDMax;

   A = pattern.A;
   B = pattern.B;
   C = pattern.C;
   D = pattern.D;

   /*
      Carney (1999, p. 118):
      I consider the completion of a exact AB = CD
      a minimun requirement before entering a trade.
   */
   if((A - B) == (C - D)) {

      ABMin = B + ((A - B) * .618);
      ABMax = B + ((A - B) * .786);

      if(C >= ABMin && C <= ABMax) {

         CDMin = C - ((C - B) * 1.618);
         CDMax = C - ((C - B) * 1.27);

         if(D >= CDMin && D <= CDMax) {
            //Print("A: ",A," B: ", B, " C: ", C, " D: ", D);
            return true;
         }
      }
   }
   return false;
}

//+-----------------------------------------+
//| Calcula o Padrão Harmônico Bearish ABCD |
//+-----------------------------------------+
bool CalculateBearishABCD(PATTERN_INSTANCE &pattern) {
   double A, B, C, D, ABMin, ABMax, CDMin, CDMax;

   A = pattern.A;
   B = pattern.B;
   C = pattern.C;
   D = pattern.A;

   if((B - A)  == (D - C)) {

      ABMin = A + ((B - A) * .618);
      ABMax = A + ((B - A) * .786);

      if(C >= ABMin && C <= ABMax) {

         CDMin = C + ((B - A) * 1.272);
         CDMax = C + ((B - A) * 1.618);

         if(C >= CDMin && C <= CDMax) {
            return true;
         }
      }
   }
   return false;
}
 
//+------------------------------------+
//| Detecta o Padrão Bullish Butterfly |
//+------------------------------------+
bool CalculateBullishButterfly( PATTERN_INSTANCE &pattern ) {
   double X, A, B, C, D, XAMin, XAMax, ABMin, ABMax, BCMin, BCMax;

   X = NormalizeDoubleDefault( pattern.X );
   A = NormalizeDoubleDefault( pattern.A );
   B = NormalizeDoubleDefault( pattern.B );
   C = NormalizeDoubleDefault( pattern.C );
   D = NormalizeDoubleDefault( pattern.D );

   XAMin = A - ( (A - X) * pattern.patternDescriptor.XAMin );
   XAMax = A - ( (A - X) * pattern.patternDescriptor.XAMax );
   ABMin = A - ( (A - B) * pattern.patternDescriptor.ABMin );
   ABMax = A - ( (A - B) * pattern.patternDescriptor.ABMax );
   BCMin = C - ( (C - B) * pattern.patternDescriptor.BCMin );
   BCMax = C - ( (C - B) * pattern.patternDescriptor.BCMax );
   
   return (
      (B >= XAMin && B <= XAMax) &&
      (C >= ABMin && C <= ABMax) &&
      (D >= BCMin && D <= BCMax)
   );
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeDoubleDefault( double i ) {
   return NormalizeDouble( i, 2 );
}
//+------------------------------------------------------------------+
