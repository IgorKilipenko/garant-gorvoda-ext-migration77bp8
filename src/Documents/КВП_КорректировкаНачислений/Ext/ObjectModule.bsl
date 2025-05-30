﻿#Область ОбработчикиСобытий

// Гарант+ Килипенко 09.02.2025 [F00234598] Доработка движений корректировки начислений ++
//
&После("ОбработкаПроведения")
Процедура ГП_ОбработкаПроведения(Отказ, РежимПроведения)
    Если Отказ Тогда
        Возврат;
    КонецЕсли;

    ЭтоДопустимыйВидОперацииКорректировки = 
        (ЭтотОбъект.ВидОперации = Перечисления.КВП_ВидыОперацийКорректировкаНачислений.КорректировкаНачислений           // Корректировка (вручную)
            ИЛИ ЭтотОбъект.ВидОперации = Перечисления.КВП_ВидыОперацийКорректировкаНачислений.Недопоставка               // Прочие перерасчеты
            ИЛИ ЭтотОбъект.ВидОперации = Перечисления.КВП_ВидыОперацийКорректировкаНачислений.ПерерасчетПоПроценту       // Перерасчет по проценту
            ИЛИ ЭтотОбъект.ВидОперации = Перечисления.КВП_ВидыОперацийКорректировкаНачислений.ПерерасчетПоПлощади        // Перерасчет по площади
            ИЛИ ЭтотОбъект.ВидОперации = Перечисления.КВП_ВидыОперацийКорректировкаНачислений.ПерерасчетКомиссииБанка);  // Перерасчет комиссии банка

    Если (ЭтоДопустимыйВидОперацииКорректировки = Истина)
            И НЕ УПЖКХ_ПараметрыУчетаСервер.ИспользоватьНовыйМеханизмОтраженияНачисленийВРеглУчете(ЭтотОбъект.Дата) Тогда

        // Перезаполнение движений отражения в рег. учете в разрезе лицевых счетов
        ГП_РаботаСНачислениемУслуг.ДополнитьДвиженияОтраженияДаннымиЛС(
            ЭтотОбъект.Движения.УПЖКХ_Начисления, ЭтотОбъект.Движения.КВП_НачислениеДляОтраженияВРеглУчете);

        СтавкаНДСДляПерерасчета = ГП_ОбщегоНазначения.ПолучитьОбщуюСтавкуНДСНачисленийЖКХ(ЭтотОбъект.Дата);

        // Перерасчет сумм движений взаиморасчетов с учетом НДС
        ГП_РаботаСНачислениемУслуг.ПересчитатьСуммыДвиженийНачисленийИВзаиморасчетовСУчетомНДС(
            ЭтотОбъект.Движения.УПЖКХ_Начисления, Ложь, СтавкаНДСДляПерерасчета);

        // Перерасчет сумм движений начислений с учетом НДС
        ГП_РаботаСНачислениемУслуг.ПересчитатьСуммыДвиженийНачисленийИВзаиморасчетовСУчетомНДС(
            ЭтотОбъект.Движения.КВП_ВзаиморасчетыПоЛицевымСчетам, Ложь, СтавкаНДСДляПерерасчета);
    КонецЕсли;
КонецПроцедуры // Гарант+ Килипенко 09.02.2025 [F00234598] Доработка движений корректировки начислений --

#КонецОбласти // ОбработчикиСобытий
