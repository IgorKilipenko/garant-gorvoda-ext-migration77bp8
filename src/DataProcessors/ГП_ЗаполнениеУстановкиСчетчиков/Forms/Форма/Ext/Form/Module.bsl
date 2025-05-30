﻿// ++ Гарант+ Килипенко 25.07.2024 [F00226454] заполнение документов Установка счетчика ++
#Область ОбработчикиСобытийФормы

//
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
    ЭтотОбъект.ДатаУстановки = Дата(2024, 07, 01);
    ЭтотОбъект.ТолькоСчетчикиБП77 = Истина;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы
// -- Гарант+ Килипенко 25.07.2024 [F00226454] заполнение документов Установка счетчика --

// ++ Гарант+ Килипенко 25.07.2024 [F00226454] заполнение документов Установка счетчика ++
#Область ОбработчикиКомандФормы

// Команда выполняет создание документа Установка счетчика со списком счетчиков лицевых счетов
&НаКлиенте
Асинх Процедура ЗаполнитьДокументыУстановки(Команда)
    РезультатДиалога = Ждать ВопросАсинх(
            "Процедура выполнит создание документа Установка счетчика по данным из БП 7.7.
            |Продолжить?", РежимДиалогаВопрос.ДаНет, , , "Внимание!");
    Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
        Возврат;
    КонецЕсли;

    // Создание и заполнение документа Установка счетчика
    РезультатСоздания = ЗаполнитьДокументыУстановкиНаСервере(ЭтотОбъект.ДатаУстановки);

    // Вывод сообщения о результате выполнения
    Если РезультатСоздания.Успех = Ложь Тогда
        ОбщегоНазначенияКлиент.СообщитьПользователю(
            СтрШаблон("Создание документа не выполнено.
                |Сообщение о причине: %1", РезультатСоздания.СообщениеОбОшибке));
    Иначе
        ОбщегоНазначенияКлиент.СообщитьПользователю(
            СтрШаблон("Создание документа Установка счетчика выполнено успешно.
                |Создано ""%1"" строк установок счетчиков.", РезультатСоздания.УстановленныеСчетчики.Количество()));
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Асинх Процедура УстановитьВиртуальныеСчетчики(Команда)
    РезультатДиалога = Ждать ВопросАсинх(
            "Процедура выполнит создание документа Установка счетчика (виртуальные счетчики).
            |Продолжить?", РежимДиалогаВопрос.ДаНет, , , "Внимание!");
    Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
        Возврат;
    КонецЕсли;

    // Создание и заполнение документа Установка счетчика
    РезультатСоздания = ЗаполнитьДокументыУстановкиВиртуальныхСчетчиковНаСервере(ЭтотОбъект.ДатаУстановки);

    // Вывод сообщения о результате выполнения
    Если РезультатСоздания.Успех = Ложь Тогда
        ОбщегоНазначенияКлиент.СообщитьПользователю(
            СтрШаблон("Создание документа не выполнено.
                |Сообщение о причине: %1", РезультатСоздания.СообщениеОбОшибке));
    Иначе
        ОбщегоНазначенияКлиент.СообщитьПользователю(
            СтрШаблон("Создание документа Установка счетчика выполнено успешно.
                |Создано ""%1"" строк установок счетчиков.", РезультатСоздания.УстановленныеСчетчики.Количество()));
    КонецЕсли;
КонецПроцедуры

// Гарант+ Килипенко 03.10.2024 [F00229366] создание и установка счетчиков с методом по среднему ++
//
// Выполняет создание виртуальных счетчиков (расчет по среднему)
&НаКлиенте
Асинх Процедура СоздатьВиртуальныеСчетчики(Команда)
    РезультатДиалога = Ждать ВопросАсинх(
            "Процедура выполнит создание виртуальных счетчиков (с методом расчета: По среднему) по данным БП 7.7.
            |Продолжить?", РежимДиалогаВопрос.ДаНет, , , "Внимание!");
    Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
        Возврат;
    КонецЕсли;

    // Создание счетчиков
    РезультатСоздания = СоздатьВиртуальныеСчетчикиНаСервере(ЭтотОбъект.ДатаУстановки);

    // Вывод сообщения о результате выполнения
    Если РезультатСоздания.Успех = Ложь Тогда
        ОбщегоНазначенияКлиент.СообщитьПользователю(
            СтрШаблон("Создание счетчиков не выполнено.
                |Сообщение о причине: %1", РезультатСоздания.ТекстСообщения));
    Иначе
        ОбщегоНазначенияКлиент.СообщитьПользователю(
            СтрШаблон("Создание счетчиков выполнено успешно.
                |Создано ""%1"" счетчиков для начисления по среднему значению.", РезультатСоздания.СозданныеЭлементы.Количество()));
    КонецЕсли;
КонецПроцедуры // Гарант+ Килипенко 03.10.2024 [F00229366] создание и установка счетчиков с методом по среднему --

// Гарант+ Килипенко 03.10.2024 [F00229366] создание и установка счетчиков с методом по среднему ++
//
// Устарела. Только для разработки
&НаКлиенте
Асинх Процедура УдалитьВиртуальныеСчетчики(Команда)
    РезультатДиалога = Ждать ВопросАсинх(
            "Будет выполнена команда удаления созданных виртуальных счетчиков.
            |Продолжить?", РежимДиалогаВопрос.ДаНет, , , "Внимание!");
    Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
        Возврат;
    КонецЕсли;

    КоличествоУдаленных = УдалитьСозданныеВиртуальныеСчетчикиНаСервере();

    ОбщегоНазначенияКлиент.СообщитьПользователю(
        СтрШаблон("Удалено ""%1"" счетчиков", КоличествоУдаленных));
КонецПроцедуры // Гарант+ Килипенко 03.10.2024 [F00229366] создание и установка счетчиков с методом по среднему --

#КонецОбласти // ОбработчикиКомандФормы
// -- Гарант+ Килипенко 25.07.2024 [F00226454] заполнение документов Установка счетчика --

// ++ Гарант+ Килипенко 25.07.2024 [F00226454] заполнение документов Установка счетчика ++
#Область СлужебныеПроцедурыИФункции

// Выполняет создание документа Установка счетчика со списком счетчиков лицевых счетов
// Параметры:
//  ДатаУстановки - Дата
// Возвращаемое значение:
//  - Структура:
//      * Успех - Булево
//      * УстановленныеСчетчики - Массив из СправочникСсылка.КВП_Счетчики
//      * СообщениеОбОшибке - Строка, Неопределено
&НаСервереБезКонтекста
Функция ЗаполнитьДокументыУстановкиНаСервере(Знач ДатаУстановки)
    ДатаУстановки = ?(ЗначениеЗаполнено(ДатаУстановки), НачалоДня(ДатаУстановки), Неопределено);
    РезультатФункции = Обработки.ГП_ЗаполнениеУстановкиСчетчиков.СоздатьДокументыУстановкиСчетчиков(ДатаУстановки, Ложь);
    Возврат РезультатФункции;
КонецФункции

// Выполняет создание документа Установка счетчика со списком счетчиков лицевых счетов
// Параметры:
//  ДатаУстановки - Дата
// Возвращаемое значение:
//  - Структура:
//      * Успех - Булево
//      * УстановленныеСчетчики - Массив из СправочникСсылка.КВП_Счетчики
//      * СообщениеОбОшибке - Строка, Неопределено
&НаСервереБезКонтекста
Функция ЗаполнитьДокументыУстановкиВиртуальныхСчетчиковНаСервере(Знач ДатаУстановки)
    ДатаУстановки = ?(ЗначениеЗаполнено(ДатаУстановки), НачалоДня(ДатаУстановки), Неопределено);
    РезультатФункции = Обработки.ГП_ЗаполнениеУстановкиСчетчиков.СоздатьДокументыУстановкиСчетчиков(ДатаУстановки, Истина);
    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 03.10.2024 [F00229366] создание и установка счетчиков с методом по среднему ++
//
&НаСервереБезКонтекста
Функция СоздатьВиртуальныеСчетчикиНаСервере(Знач ДатаУстановки)
    ДатаУстановки = ?(ЗначениеЗаполнено(ДатаУстановки), НачалоДня(ДатаУстановки), Неопределено);
    РезультатФункции = ГП_МиграцияПриборовУчета.СоздатьСчетчикиПоСреднемуМетодуРасчета(ДатаУстановки);
    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 03.10.2024 [F00229366] создание и установка счетчиков с методом по среднему --

// Гарант+ Килипенко 03.10.2024 [F00229366] создание и установка счетчиков с методом по среднему ++
//
// Устарела. Только для разработки
&НаСервереБезКонтекста
Функция УдалитьСозданныеВиртуальныеСчетчикиНаСервере()
    РезультатФункции = ГП_МиграцияПриборовУчета.УдалитьВиртуальныеСчетчики();
    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 03.10.2024 [F00229366] создание и установка счетчиков с методом по среднему --

#КонецОбласти // СлужебныеПроцедурыИФункции
// -- Гарант+ Килипенко 25.07.2024 [F00226454] заполнение документов Установка счетчика --
