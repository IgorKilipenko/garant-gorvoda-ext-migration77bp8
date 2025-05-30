﻿// ++ Гарант+ Килипенко 15.07.2024 [F00225713] Перенос из БП 7.7 в БП3 справочника Счетчики ++
#Область ОпределениеПеременных

&НаКлиенте
Перем ДоступноРедактированиеРеквизитовФормы;

#КонецОбласти // ОпределениеПеременных
// -- Гарант+ Килипенко 15.07.2024 [F00225713] Перенос из БП 7.7 в БП3 справочника Счетчики --

// ++ Гарант+ Килипенко 15.07.2024 [F00225713] Перенос из БП 7.7 в БП3 справочника Счетчики ++
#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
    ДоступноРедактированиеРеквизитовФормы = Ложь;
    НастроитьДоступностьЭлементовФормы();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы
// -- Гарант+ Килипенко 15.07.2024 [F00225713] Перенос из БП 7.7 в БП3 справочника Счетчики --

// ++ Гарант+ Килипенко 15.07.2024 [F00225713] Перенос из БП 7.7 в БП3 справочника Счетчики ++
#Область ОбработчикиКомандФормы

// Включает / выключает возможность редактирования формы
&НаКлиенте
Процедура РазрешитьРедактирование(Команда)
    ДоступноРедактированиеРеквизитовФормы = НЕ ДоступноРедактированиеРеквизитовФормы;
    НастроитьДоступностьЭлементовФормы();
КонецПроцедуры

#КонецОбласти // ОбработчикиКомандФормы
// -- Гарант+ Килипенко 15.07.2024 [F00225713] Перенос из БП 7.7 в БП3 справочника Счетчики --

// ++ Гарант+ Килипенко 15.07.2024 [F00225713] Перенос из БП 7.7 в БП3 справочника Счетчики ++
#Область СлужебныеПроцедурыИФункции

// Выполняет настройку доступности для редактирования элементов формы
&НаКлиенте
Процедура НастроитьДоступностьЭлементовФормы()
    РедактируемыеЭлементыФормы = ПолучитьДоступныеДляРедактированияЭлементы();
    Для каждого Элемент Из РедактируемыеЭлементыФормы Цикл
        Элемент.ТолькоПросмотр = НЕ ДоступноРедактированиеРеквизитовФормы;
    КонецЦикла;
КонецПроцедуры

// Возвращаемое значение:
//  - Массив из ЭлементФормы
&НаКлиенте
Функция ПолучитьДоступныеДляРедактированияЭлементы()
    РезультатФункции = Новый Массив;

    РезультатФункции.Добавить(ЭтотОбъект.Элементы.КонтрагентКод);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ОбъектАбонентаКод);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.СчетчикКод);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.Счетчик);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.СчетчикНаименование);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ДоговорКод);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ТипСчетчикаКод);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ПериодичностьПоверки);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.КоэффициентПересчета);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.МаксимальныйПоказатель);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ВидСчетчика);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.МетодРасчетаХВ);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.МетодРасчетаГВ);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.МетодРасчетаКан);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ТолькоДляКанализации);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ДатаУстановки);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ДатаПоверки);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ЗначенияПоказаний);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.КонтрагентИНН);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.КонтрагентНаименование);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ОбъектАбонентаНаименование);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ДоговорНаименование);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ДоговорНомер);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ТипСчетчикаНаименование);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ДатаПоказаний);
    РезультатФункции.Добавить(ЭтотОбъект.Элементы.ДатаБудущейПоверки);

    Возврат РезультатФункции;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
// -- Гарант+ Килипенко 15.07.2024 [F00225713] Перенос из БП 7.7 в БП3 справочника Счетчики --
