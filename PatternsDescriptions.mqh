//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define PATTERNS_COUNT 14
#define FOUR_POINTERS_PATTERNS_COUNT 2
#define FIVE_POINTERS_PATTERNS_COUNT 12
#define FIVE_BULLISH_POINTERS_PATTERNS_COUNT 6
#define FIVE_BEARISH_POINTERS_PATTERNS_COUNT 6

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


PATTERN_INDEX FIVE_POINTERS_BULLISH_PATTERNS[FIVE_BULLISH_POINTERS_PATTERNS_COUNT] = {
   BULLISH_GARTLEY,
   BULLISH_BUTTERFLY,
   BULLISH_BAT,
   BULLISH_CRAB,
   BULLISH_DEEP_CRAB,
   BULLISH_SHARK,
};

PATTERN_INDEX FIVE_POINTERS_BEARISH_PATTERNS[FIVE_BEARISH_POINTERS_PATTERNS_COUNT] = {
   BEARISH_GARTLEY,
   BEARISH_BUTTERFLY,
   BEARISH_BAT,
   BEARISH_CRAB,
   BEARISH_DEEP_CRAB,
   BEARISH_SHARK,
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

PATTERN_DESCRIPTOR patternsDescriptors[PATTERNS_COUNT];

//+------------------------------------------------------------------+
//| Popula o array com as ratios de fibo de cada Padrão Harmônico    |
//+------------------------------------------------------------------+
void PopulatePatternsDescriptors() {
   PATTERN_DESCRIPTOR bullishGartley = { BULLISH_GARTLEY, 0.618, 0.618, 0.618, 0.786, 1.27, 1.618, 0.786, 0.786 };
   PATTERN_DESCRIPTOR bearishGartley = { BEARISH_GARTLEY, 0.618, 0.618, 0.618, 0.786, 1.27, 1.618, 0.786, 0.786 };
   PATTERN_DESCRIPTOR bullishABCD = { BULLISH_ABCD, 0, 0, 0.618, 0.786, 1.27, 1.618, 0, 0 };
   PATTERN_DESCRIPTOR bearishABCD = { BEARISH_ABCD, 0, 0, 0.618, 0.786, 1.27, 1.618, 0, 0 };
   PATTERN_DESCRIPTOR bullishButterfly = { BULLISH_BUTTERFLY, 0.786, 0.786, 0.618, 0.786, 1.618, 1.618, 1.27, 1.618 };
   PATTERN_DESCRIPTOR bearishButterfly = { BEARISH_BUTTERFLY, 0.786, 0.786, 0.618, 0.786, 1.618, 1.618, 1.27, 1.618 };
   PATTERN_DESCRIPTOR bullishBat = { BULLISH_BAT, .382, .5, .382, .886, 1.618, 2.618, .886, .886 };
   PATTERN_DESCRIPTOR bearishBat = { BEARISH_BAT, .382, .5, .382, .886, 1.618, 2.618, .886, .886 };
   PATTERN_DESCRIPTOR bullishCrab = { BULLISH_CRAB, .382, .618, .382, .886, 2.618, 3.618, 1.618, 1.618 };
   PATTERN_DESCRIPTOR bearishCrab = { BEARISH_CRAB, .382, .618, .382, .886, 2.618, 3.618, 1.618, 1.618 };
   PATTERN_DESCRIPTOR bullishDeepCrab = { BULLISH_DEEP_CRAB, .886, .886, .382, .886, 2, 3.618, 1.618, 1.618 };
   PATTERN_DESCRIPTOR bearishDeepCrab = { BEARISH_DEEP_CRAB, .886, .886, .382, .886, 2, 3.618, 1.618, 1.618 };
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

//+-------------------------------------------------------------------+
//| Adiciona a instância do PATTERN_DESCRIPTOR ao array de que contém |
//| as ratios de cada Padrão Harmônicos                              |
//+-------------------------------------------------------------------+
void AddPatternDescriptorToArray(PATTERN_DESCRIPTOR &patternDescriptor) {
   patternsDescriptors[patternDescriptor.index] = patternDescriptor;
}

//+------------------------------------------------------------------+
