//+------------------------------------------------------------------+
//|                                                  ATR突破策略.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include  <classpack.mqh>
ClassPack CPack ;


//策略說明:
//ATR 在外匯交易中的主要用途是確定市場波動水平。 
//高ATR 值表明市場波動性增加，而低ATR 值表明市場相對穩定。 
//通過監控ATR 值，在ATR突破前14天ATR的加總時判斷行情發動，用14MA判斷方向，以一倍ATR做停損停利。
//
//參數:
//ATR 14天  停損1倍
//MA  14天



double atr_values[];             //裝atr值的陣列
double atr_handle;               //atr指標的句柄


double total_atr = 0;            //14天價格加總
double total_average_atr = 0;    //atr的平均波動

double ma_values[];              //裝iMA值的陣列
double ma_handle;                //iMA指標的句柄


double ask;                      //買入價格
double bid;                      //賣出價格



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //---
   //--- 建立iATR指標
   atr_handle = iATR(NULL,PERIOD_CURRENT,14);                      //週期14
   
   //--- 建立iMA指標
   ma_handle = iMA(NULL,PERIOD_CURRENT,14,0,MODE_SMA,PRICE_CLOSE); //週期14
   


   
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
//---


    //注意，CopyBuffer循環會影響atr_values[0]的值，所以要先做完，之後再加載一次CopyBuffer
    for(int i = 0; i < 14; i++){ //從0開始，歷遍14支atr
    
    //--- 用目前iATR的值填入atr_values[]數組
    //--- 複製1個元素
    //--- 往前偏移i個日期
    CopyBuffer(atr_handle,0,i,1,atr_values); //atr_values[0]為當前bar的atr值
    total_atr += atr_values[0]; //加總14天的atr為total_atr
    
    }
    
    total_average_atr = total_atr/14; //把14根bar的atr相加去除以14，得到平均atr
    
    
    //--- 用目前iATR的值填入atr_values[]數組
    //--- 複製1個元素
    CopyBuffer(atr_handle,0,0,1,atr_values); //atr_values[0]為當前bar的atr值
    
    //--- 用目前iMA的值填入ma_values[]數組
    //--- 複製1個元素
    CopyBuffer(ma_handle,0,0,1,ma_values); //ma_values[0]為當前bar的前一根的MA值





    ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);    //取得買入價
    bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);    //取得賣出價
    
    
    
    
    
    
    if(PositionsTotal() == 0){                                             //如果沒有持倉
      if(CPack.isnewbar() == true){                                        //如果有新的bar形成
         printf("當前ATR:" + atr_values[0]);                               //方便觀察入場時的狀態
         printf("14天平均ATR:" + total_average_atr);                       //方便觀察入場時的狀態
         if(atr_values[0] > total_average_atr){                            //如果今天的atr大於前14天的atr平均，判斷為趨勢開始
            if(bid > ma_values[0]){                                        //如果現價大於MA(14日平均值)，判斷為多頭
               trade.Buy(0.01,NULL,0,bid-atr_values[0],bid+atr_values[0]); //停損為bid-atr，停利為bid+atr                 
            }
            if(bid < ma_values[0]){                                        //如果現價小於MA(14日平均值)，判斷為空頭
               trade.Sell(0.01,NULL,0,bid+atr_values[0],bid-atr_values[0]);//停損為bid+atr，停利為bid-atr           
            }
        }  
      }   
    }
    
    
    
    
    //--- 初始化14天atr
    total_atr = 0;
    total_average_atr = 0;
    
    }
//+------------------------------------------------------------------+
