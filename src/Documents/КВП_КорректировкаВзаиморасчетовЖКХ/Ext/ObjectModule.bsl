﻿#Область ПереопределениеСтандартногоФункционала

&ИзменениеИКонтроль("ПроизвестиДвиженияПоРегиструНачислениеДляОтраженияВРеглУчете")
Процедура ГП_ПроизвестиДвиженияПоРегиструНачислениеДляОтраженияВРеглУчете(ВидДвижения, ЛицевойСчет, Договор, стр, Сумма)
	
	Движение                        = Движения.КВП_НачислениеДляОтраженияВРеглУчете.Добавить();
	Движение.Период                 = Дата;
	Движение.Активность             = Истина;
	Движение.ВидДвижения            = ВидДвижения;
	Движение.Организация            = Организация;
	Движение.ДоговорКонтрагента     = Договор;
	Движение.Номенклатура           = стр.Услуга.Услуга;
	Движение.НоменклатурнаяГруппа   = ПолучитьНоменклатурнуюГруппуДляОбъектаУчета(ЛицевойСчет, стр.Услуга.Услуга);
    #Вставка // Гарант+ Килипенко 10.02.2025 Отражение начислений корректировки по л/с ++
    
    Движение.ГП_ЛицевойСчет = ЛицевойСчет;
    
    #КонецВставки // Гарант+ Килипенко 10.02.2025 Отражение начислений корректировки по л/с --
	
	ДанныеОПоставщикеУслуги         = ПолучитьДанныеОПоставщикеУслуги(Организация,
																	  стр.Услуга, ЛицевойСчет, Дата);
	Движение.ВариантПоставкиУслуг   = ?(ДанныеОПоставщикеУслуги.ВариантПоставкиУслуг = Неопределено, 
											Перечисления.УПЖКХ_ВариантыРасчетовСПоставщикамиУслуг.КупляПродажаУслуг, 
											ДанныеОПоставщикеУслуги.ВариантПоставкиУслуг);
	Движение.ДоговорПоставщикаУслуг = ДанныеОПоставщикеУслуги.ДоговорПоставщикаУслуг;
	Движение.Сумма                  = Сумма;
    #Вставка // Гарант+ Килипенко 10.02.2025 Отражение начислений корректировки по л/с ++
    
    // Исключение суммы НДС (в том числе) из суммы начислений для отражения в рег. учете
    СтавкаНДСДляПерерасчета = ГП_ОбщегоНазначения.ПолучитьОбщуюСтавкуНДСНачисленийЖКХ(ЭтотОбъект.Дата);
    Движение.Сумма = 
        Движение.Сумма - УчетНДСКлиентСервер.РассчитатьСуммуНДС(Движение.Сумма,
            Истина, УчетНДСВызовСервераПовтИсп.ПолучитьСтавкуНДС(СтавкаНДСДляПерерасчета));
    
    #КонецВставки // Гарант+ Килипенко 10.02.2025 Отражение начислений корректировки по л/с --
	
	Если стр.ВидНачисления = Перечисления.КВП_ВидыНачисленияОстатки.Пени Тогда
		
		// Для пени по капремонту в УП есть своя настройка отдельного/совместного отражения от начислений.
		Если мСтруктураНастроекКапРемонта.ВедетсяРаздельныйУчет
			 И Не мСтруктураНастроекКапРемонта.СписокУслуг.НайтиПоЗначению(стр.Услуга) = Неопределено Тогда
			
			Движение.ЭтоПени = (мНастройкиУчетнойПолитикиТСЖ.СчетаУчетаДляОтраженияПениКапремонт = ПредопределенноеЗначение("Перечисление.УПЖКХ_СчетаУчетаДляПениПриОтраженииВРеглУчете.ОтдельныеСчета")
								Или мНастройкиУчетнойПолитикиТСЖ.СтавкаНДСДляОтраженияПени = Перечисления.УПЖКХ_СтавкиНДСДляПениПриОтраженииВРеглУчете.БезНДС);
			
		Иначе
			
			Движение.ЭтоПени = (мНастройкиУчетнойПолитикиТСЖ.СчетаУчетаДляОтраженияПени = ПредопределенноеЗначение("Перечисление.УПЖКХ_СчетаУчетаДляПениПриОтраженииВРеглУчете.ОтдельныеСчета")
								Или мНастройкиУчетнойПолитикиТСЖ.СтавкаНДСДляОтраженияПени = Перечисления.УПЖКХ_СтавкиНДСДляПениПриОтраженииВРеглУчете.БезНДС);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти // ПереопределениеСтандартногоФункционала