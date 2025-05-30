﻿// Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления ++
#Область СлужебныйПрограммныйИнтерфейс

// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Объект - СправочникСсылка.КВП_ЛицевыеСчета
//      * ДокументОплаты - ДокументСсылка
//      * Сумма - Число
//      * Помещение - СправочникСсылка.УПЖКХ_Помещения
//      * Здание - СправочникСсылка.КВП_Здания
//      * Владелец - СправочникСсылка.Контрагенты
Функция НовыйТаблицаОплатПоЛицевымСчетам() Экспорт
    РезультатФункции = Новый ТаблицаЗначений;

    ДокументОбъект = Документы.КВП_РегистрацияОплаты.СоздатьДокумент();
    РезультатФункции = ДокументОбъект.ЛицевыеСчета.ВЫгрузитьКолонки();

    РезультатФункции.Колонки.Добавить("Помещение", Новый ОписаниеТипов("СправочникСсылка.УПЖКХ_Помещения"));
    РезультатФункции.Колонки.Добавить("Здание", Новый ОписаниеТипов("СправочникСсылка.КВП_Здания"));
    РезультатФункции.Колонки.Добавить("Владелец", Новый ОписаниеТипов("СправочникСсылка.Контрагенты"));

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  ТаблицаНачисленийНаЛС - ТаблицаЗначений
// Возвращаемое значение:
//  - Структура
//      * ДанныеДляПропорциональногоРаспределения - ТаблицаЗначений
//      * ДанныеДляРавномерногоРаспределения - ТаблицаЗначений
Функция ПодготовитьСтруктуруДанныхДляРаспределенияОплаты(Знач ТаблицаНачисленийНаЛС) Экспорт
    РезультатФункции = Новый Структура("ДанныеДляПропорциональногоРаспределения, ДанныеДляРавномерногоРаспределения");

    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |   *
        |ПОМЕСТИТЬ ВТ_ТаблицаНачисленийНаЛС
        |ИЗ
        |   &ТаблицаНачисленийНаЛС КАК ТаблицаНачисленийНаЛС
        |;
        |
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |   *
        |ИЗ
        |   ВТ_ТаблицаНачисленийНаЛС КАК ВТ_ТаблицаНачисленийНаЛС
        |ГДЕ
        |   ВТ_ТаблицаНачисленийНаЛС.СуммаНачисленияОстаток > 0
        |;
        |
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |   *
        |ИЗ
        |   ВТ_ТаблицаНачисленийНаЛС КАК ВТ_ТаблицаНачисленийНаЛС
        |;
        |";

    Запрос.УстановитьПараметр("ТаблицаНачисленийНаЛС", ТаблицаНачисленийНаЛС);
    РезультатПакетаЗапроса = Запрос.ВыполнитьПакет();

    РезультатФункции.ДанныеДляПропорциональногоРаспределения = РезультатПакетаЗапроса[1].Выгрузить();
    РезультатФункции.ДанныеДляРавномерногоРаспределения = РезультатПакетаЗапроса[2].Выгрузить();

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  СуммаРаспределения - Число
//  ОбщаяСуммаНачислений - Число
//  ДанныеДляРаспределения - ТаблицаЗначений
//  ДокументОплаты - ДокументСсылка
//  Контрагент - СправочникСсылка.Контрагенты
//  РаспределятьРавномерно - Булево
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Объект - СправочникСсылка.КВП_ЛицевыеСчета
//      * ДокументОплаты - ДокументСсылка
//      * Сумма - Число
//      * Помещение - СправочникСсылка.УПЖКХ_Помещения
//      * Здание - СправочникСсылка.КВП_Здания
//      * Владелец - СправочникСсылка.Контрагенты
Функция СформироватьТаблицуРаспределенияОплаты(
        Знач СуммаРаспределения, Знач ОбщаяСуммаНачислений, Знач ДанныеДляРаспределения, Знач ДокументОплаты, Знач Контрагент, Знач РаспределятьРавномерно = Ложь) Экспорт

    РезультатФункции = НовыйТаблицаОплатПоЛицевымСчетам();

    Если ДанныеДляРаспределения.Количество() = 0 Тогда
        Возврат РезультатФункции; // Нет данных для распределения
    КонецЕсли;

    НераспределеннаяСумма = СуммаРаспределения;
    СтрокаМаксимальнойСуммы = Неопределено;
    Для Каждого СтрокаЛС Из ДанныеДляРаспределения Цикл
        КоэффициентРаспределенияЛС = РассчитатьКоэффициентРаспределения(
                СтрокаЛС.СуммаНачисленияОстаток, ОбщаяСуммаНачислений, ?(РаспределятьРавномерно = Истина,
                    ДанныеДляРаспределения.Количество(), Неопределено));

        #Область Отладка
        ГП_ДиагностикаКлиентСервер.Утверждение(КоэффициентРаспределенияЛС >= 0,
            "Коэффициент распределения должен не может иметь отрицательное значение");
        #КонецОбласти // Отладка

        НоваяСтрокаЛС = РезультатФункции.Добавить();

        НоваяСтрокаЛС.Объект = СтрокаЛС.ЛицевойСчет;
        НоваяСтрокаЛС.ДокументОплаты = ДокументОплаты;
        НоваяСтрокаЛС.Сумма = ?(КоэффициентРаспределенияЛС = 1,
                СтрокаЛС.СуммаНачисленияОстаток,
                Окр(СуммаРаспределения * КоэффициентРаспределенияЛС, 2, 0));

        НоваяСтрокаЛС.Помещение = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаЛС.ЛицевойСчет, "Адрес");
        НоваяСтрокаЛС.Здание = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(НоваяСтрокаЛС.Помещение, "Владелец");
        НоваяСтрокаЛС.Владелец = Контрагент;

        НераспределеннаяСумма = НераспределеннаяСумма - НоваяСтрокаЛС.Сумма;

        Если СтрокаМаксимальнойСуммы = Неопределено Тогда
            СтрокаМаксимальнойСуммы = НоваяСтрокаЛС;
        КонецЕсли;

        Если СтрокаМаксимальнойСуммы.Сумма < НоваяСтрокаЛС.Сумма Тогда
            СтрокаМаксимальнойСуммы = НоваяСтрокаЛС;
        КонецЕсли;
    КонецЦикла;

    Если НераспределеннаяСумма <> 0 И СтрокаМаксимальнойСуммы <> Неопределено Тогда
        СтрокаМаксимальнойСуммы.Сумма =
            СтрокаМаксимальнойСуммы.Сумма + НераспределеннаяСумма;
    КонецЕсли;

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  СписокЛицевыхСчетов - Массив, СписокЗначений из СправочникСсылка.КВП_ЛицевыеСчета
//  ОрганизацияСсылка - СправочникСсылка.Организации, Неопределено
//  Период - Дата, Неопределено
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * ЛицевойСчет - СправочникСсылка.КВП_ЛицевыеСчета
//      * СуммаНачисленияОстаток - Число
Функция ПолучитьНачисленияДляСпискаЛицевыхСчетов(
        Знач СписокЛицевыхСчетов, Знач ОрганизацияСсылка = Неопределено, Знач Период = Неопределено) Экспорт

    ОрганизацияСсылка = ?(ОрганизацияСсылка = Неопределено,
            УПЖКХ_ТиповыеМетодыВызовСервера.ПолучитьОсновнуюОрганизацию(), ОрганизацияСсылка);

    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	КВП_ВзаиморасчетыПоЛицевымСчетамОстатки.ЛицевойСчет КАК ЛицевойСчет,
        |	КВП_ВзаиморасчетыПоЛицевымСчетамОстатки.СуммаНачисленияОстаток КАК СуммаНачисленияОстаток
        |ИЗ
        |	РегистрНакопления.КВП_ВзаиморасчетыПоЛицевымСчетам.Остатки(&Период, ЛицевойСчет В (&СписокЛицевыхСчетов) И Организация = &Организация) КАК КВП_ВзаиморасчетыПоЛицевымСчетамОстатки
        |";

    Запрос.УстановитьПараметр("СписокЛицевыхСчетов", СписокЛицевыхСчетов);
    Если Период = Неопределено Тогда
        Запрос.Текст = СтрЗаменить(Запрос.Текст, "&Период", "");
    Иначе
        Запрос.УстановитьПараметр("Период", Период);
    КонецЕсли;
    Запрос.УстановитьПараметр("Организация", ОрганизацияСсылка);

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  СуммаНачисления - Число
//  СуммаРаспределения - Число
//  КоличествоСтрокРаспределения - Число, Неопределено
// Возвращаемое значение:
//  - Число
Функция РассчитатьКоэффициентРаспределения(
        Знач СуммаНачисления, Знач СуммаРаспределения, Знач КоличествоСтрокРаспределения = Неопределено) Экспорт

    КоэффициентРаспределенияЛС = 1;

    РаспределятьРавномерно = КоличествоСтрокРаспределения <> Неопределено;

    Если РаспределятьРавномерно = Ложь Тогда
        Если СуммаНачисления <> СуммаРаспределения Тогда
            КоэффициентРаспределенияЛС = ?(СуммаРаспределения > 0,
                    СуммаНачисления / СуммаРаспределения, 0);
        КонецЕсли;
    Иначе
        КоэффициентРаспределенияЛС = ?(КоличествоСтрокРаспределения = 0, 0, КоэффициентРаспределенияЛС / КоличествоСтрокРаспределения);
    КонецЕсли;

    Возврат КоэффициентРаспределенияЛС;
КонецФункции

// Параметры:
//  ТаблицаНачисленийНаЛС - ТаблицаЗначений
//  СуммаРаспределения - Число
//  ДокументОплаты - ДокументСсылка
//  Контрагент - СправочникСсылка.Контрагенты
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Объект - СправочникСсылка.КВП_ЛицевыеСчета
//      * ДокументОплаты - ДокументСсылка
//      * Сумма - Число
//      * Помещение - СправочникСсылка.УПЖКХ_Помещения
//      * Здание - СправочникСсылка.КВП_Здания
//      * Владелец - СправочникСсылка.Контрагенты
Функция СформироватьТаблицуОплатДляСпискаЛС(
        Знач ТаблицаНачисленийНаЛС, Знач СуммаРаспределения, Знач ДокументОплаты, Знач Контрагент) Экспорт

    СтруктураДанныхДляРаспределения = ПодготовитьСтруктуруДанныхДляРаспределенияОплаты(ТаблицаНачисленийНаЛС);
    ДанныеДляПропорциональногоРаспределения = СтруктураДанныхДляРаспределения.ДанныеДляПропорциональногоРаспределения;
    ДанныеДляРавномерногоРаспределения = СтруктураДанныхДляРаспределения.ДанныеДляРавномерногоРаспределения;

    СуммаНачисленияНаВсеЛС = ДанныеДляПропорциональногоРаспределения.Итог("СуммаНачисленияОстаток");
    СуммаДляПропорциональногоРаспределения = Мин(Макс(СуммаНачисленияНаВсеЛС, 0), СуммаРаспределения);
    СуммаДляРавномерногоРаспределения = СуммаРаспределения - СуммаДляПропорциональногоРаспределения;

    #Область Отладка
    ГП_ДиагностикаКлиентСервер.Утверждение(СуммаДляПропорциональногоРаспределения >= 0 И СуммаДляРавномерногоРаспределения >= 0,
        "Сумма распределения не может быть меньше 0");
    #КонецОбласти // Отладка

    СтруктураПараметровЗаполнения = Новый Структура;
    СтруктураПараметровЗаполнения.Вставить("СуммаРаспределения", СуммаДляПропорциональногоРаспределения);
    СтруктураПараметровЗаполнения.Вставить("ОбщаяСуммаНачислений", СуммаНачисленияНаВсеЛС);
    СтруктураПараметровЗаполнения.Вставить("ДокументОплаты", ДокументОплаты);
    СтруктураПараметровЗаполнения.Вставить("Контрагент", Контрагент);
    СтруктураПараметровЗаполнения.Вставить("РаспределятьРавномерно", Ложь);

    // Основной цикл распределения по л/с где есть суммы на оплату (долг)
    РезультатФункции = СформироватьТаблицуРаспределенияОплаты(
            СтруктураПараметровЗаполнения.СуммаРаспределения,
            СтруктураПараметровЗаполнения.ОбщаяСуммаНачислений,
            ДанныеДляПропорциональногоРаспределения,
            СтруктураПараметровЗаполнения.ДокументОплаты,
            СтруктураПараметровЗаполнения.Контрагент,
            ?(СтруктураПараметровЗаполнения.Свойство("РаспределятьРавномерно"),
                СтруктураПараметровЗаполнения.РаспределятьРавномерно, Ложь));

    // Распределение аванса
    Если СуммаДляРавномерногоРаспределения > 0 И ДанныеДляРавномерногоРаспределения.Количество() > 0 Тогда
        //#Область Отладка
        //ГП_ДиагностикаКлиентСервер.Утверждение(ДанныеДляРавномерногоРаспределения.Количество() > 0,
        //    "Нет данных л/с для равномерного распределения");
        //#КонецОбласти // Отладка

        СтруктураПараметровЗаполнения.РаспределятьРавномерно = Истина;
        СтруктураПараметровЗаполнения.СуммаРаспределения = СуммаДляРавномерногоРаспределения;

        ДанныеЗаполненияРавномерно = СформироватьТаблицуРаспределенияОплаты(
                СтруктураПараметровЗаполнения.СуммаРаспределения,
                СтруктураПараметровЗаполнения.ОбщаяСуммаНачислений,
                ДанныеДляРавномерногоРаспределения,
                СтруктураПараметровЗаполнения.ДокументОплаты,
                СтруктураПараметровЗаполнения.Контрагент,
                ?(СтруктураПараметровЗаполнения.Свойство("РаспределятьРавномерно"),
                    СтруктураПараметровЗаполнения.РаспределятьРавномерно, Ложь));

        ОбщегоНазначенияКлиентСервер.ДополнитьТаблицу(ДанныеЗаполненияРавномерно, РезультатФункции);
    КонецЕсли;

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  Дата - Дата
//  Контрагент - СправочникСсылка.Контрагенты
//  СуммаРаспределенияПоЛС - Число
//  ДокументОплаты - ДокументСсылка
//  Организация - СправочникСсылка.Организации
//  СписокЛицевыхСчетов - СписокЗначений из СправочникСсылка.КВП_ЛицевыеСчета
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Объект - СправочникСсылка.КВП_ЛицевыеСчета
//      * ДокументОплаты - ДокументСсылка
//      * Сумма - Число
//      * Помещение - СправочникСсылка.УПЖКХ_Помещения
//      * Здание - СправочникСсылка.КВП_Здания
//      * Владелец - СправочникСсылка.Контрагенты
Функция СформироватьТаблицуОплатПоКонтрагенту(Знач Дата, Знач Контрагент,
        Знач СуммаРаспределенияПоЛС, Знач ДокументОплаты, Знач Организация, Знач СписокЛицевыхСчетов) Экспорт

    // Получение данные взаиморасчетов по л/с
    ТаблицаНачисленийНаЛС = ПолучитьНачисленияДляСпискаЛицевыхСчетов(
            СписокЛицевыхСчетов, Организация, Новый Граница(Дата, ВидГраницы.Исключая));

    Если ТаблицаНачисленийНаЛС.Количество() = 0 Тогда
        // Если нет остатков по взаиморасчетам но есть л/с
        Для Каждого ТекущийЛС Из СписокЛицевыхСчетов Цикл
            НоваяСтрокаДанных = ТаблицаНачисленийНаЛС.Добавить();
            НоваяСтрокаДанных.ЛицевойСчет = ТекущийЛС;
            НоваяСтрокаДанных.СуммаНачисленияОстаток = 0;
        КонецЦикла;
    КонецЕсли;

    // Формирования таблицы данных распределения оплаты по л/с
    ДанныеЗаполнения = СформироватьТаблицуОплатДляСпискаЛС(
            ТаблицаНачисленийНаЛС, СуммаРаспределенияПоЛС, ДокументОплаты, Контрагент);

    Возврат ДанныеЗаполнения;
КонецФункции

// Параметры:
//  ДокументОплатыСсылка - ДокументСсылка.КВП_РегистрацияОплаты
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * ДокументРегистрацииОплаты - ДокументСсылка.КВП_РегистрацияОплаты
//      * ДокументОплаты - ДокументСсылка.ПоступлениеНаРасчетныйСчет, ДокументСсылка.ПриходныйКассовыйОрдер, ДокументСсылка.ОплатаПлатежнойКартой
//      * Сумма - Число
Функция ПолучитьРанееРаспределенныеСуммыДокументаОплаты(Знач ДокументОплатыСсылка) Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	РегистрацияОплатыЛицевыеСчета.Ссылка КАК РегистрацияОплаты,
        |	РегистрацияОплатыЛицевыеСчета.НомерСтроки КАК НомерСтроки,
        |	РегистрацияОплатыЛицевыеСчета.Объект КАК Объект,
        |	РегистрацияОплатыЛицевыеСчета.Сумма КАК Сумма,
        |	РегистрацияОплатыЛицевыеСчета.СуммаПоГрафику КАК СуммаПоГрафику,
        |	РегистрацияОплатыЛицевыеСчета.ФлагРедактирования КАК ФлагРедактирования,
        |	РегистрацияОплатыЛицевыеСчета.ВариантРаспределения КАК ВариантРаспределения,
        |	РегистрацияОплатыЛицевыеСчета.ВариантОплаты КАК ВариантОплаты,
        |	РегистрацияОплатыЛицевыеСчета.РаспределятьПоУказаннымУслугам КАК РаспределятьПоУказаннымУслугам,
        |	РегистрацияОплатыЛицевыеСчета.ДокументОплаты КАК ДокументОплаты,
        |	РегистрацияОплатыЛицевыеСчета.ИдентификаторСтрокиЛС КАК ИдентификаторСтрокиЛС
        |ПОМЕСТИТЬ ВТ_РегистрацияОплатыЛицевыеСчета
        |ИЗ
        |	Документ.КВП_РегистрацияОплаты.ЛицевыеСчета КАК РегистрацияОплатыЛицевыеСчета
        |ГДЕ
        |	РегистрацияОплатыЛицевыеСчета.Ссылка.Проведен = ИСТИНА
        |	И РегистрацияОплатыЛицевыеСчета.ДокументОплаты = &ДокументОплаты
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ВТ_РегистрацияОплатыЛицевыеСчета.РегистрацияОплаты КАК ДокументРегистрацииОплаты,
        |	ВТ_РегистрацияОплатыЛицевыеСчета.ДокументОплаты КАК ДокументОплаты,
        |	СУММА(ВТ_РегистрацияОплатыЛицевыеСчета.Сумма) КАК Сумма
        |ИЗ
        |	ВТ_РегистрацияОплатыЛицевыеСчета КАК ВТ_РегистрацияОплатыЛицевыеСчета
        |
        |СГРУППИРОВАТЬ ПО
        |	ВТ_РегистрацияОплатыЛицевыеСчета.РегистрацияОплаты,
        |	ВТ_РегистрацияОплатыЛицевыеСчета.ДокументОплаты
        |";

    Запрос.УстановитьПараметр("ДокументОплаты", ДокументОплатыСсылка);

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции

// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * ОбщаяРаспределеннаяСумма - Число
//      * ДокументыРегистрации - Массив из ДокументСсылка
Функция ВыполнитьКонтрольРанееРаспределенныхСуммДокумента(Знач ДокументОплатыСсылка, Знач СуммаДокумента = Неопределено) Экспорт
    РезультатФункции = Новый Структура("Успех, ОбщаяРаспределеннаяСумма, ДокументыРегистрации", Истина, 0, Новый Массив);

    Если СуммаДокумента = Неопределено Тогда
        ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументОплатыСсылка, "СуммаДокумента");
    КонецЕсли;

    ДанныеРанееРаспределенныхСумм = ГП_РегистрацияОплатыСлужебный.ПолучитьРанееРаспределенныеСуммыДокументаОплаты(ДокументОплатыСсылка);
    Для Каждого СтрокаДанных Из ДанныеРанееРаспределенныхСумм Цикл
        РезультатФункции.ДокументыРегистрации.Добавить(СтрокаДанных.ДокументРегистрацииОплаты);
        РезультатФункции.ОбщаяРаспределеннаяСумма = РезультатФункции.ОбщаяРаспределеннаяСумма + СтрокаДанных.Сумма;
    КонецЦикла;

    РезультатФункции.Успех = РезультатФункции.ОбщаяРаспределеннаяСумма <= СуммаДокумента;

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  ДокументОплаты - СправочникСсылка.ДоговорыКонтрагентов
// Возвращаемое значение:
//  - СправочникСсылка.ДоговорыКонтрагентов, Неопределено
Функция ПолучитьДоговорКонтрагентаДокументаОплаты(Знач ДокументОплаты) Экспорт
    РезультатФункции = Неопределено;

    Попытка
        РезультатФункции = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументОплаты, "ДоговорКонтрагента");
    Исключение
        РезультатФункции = Неопределено;
    КонецПопытки;

    Если ТипЗнч(РезультатФункции) <> Тип("СправочникСсылка.ДоговорыКонтрагентов") Тогда
        РезультатФункции = Неопределено;
    КонецЕсли;

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  ДокументРегистрацииСсылка - ДокументСсылка.КВП_РегистрацияОплаты
//  СтрогийРежимКонтроля - Булево
//  ДобавитьВПредставлениеИНН - Булево
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * Контрагент - СправочникСсылка.Контрагенты, Неопределено
//      * ПредставлениеПлательщика - Строка, Неопределено
//      * РезультатФункции - Структура, Неопределено
//      * ПринятоОт - Строка, Неопределено
//      * СтрогийРежимКонтроля - Строка, Неопределено - По умолчанию Истина
Функция ПолучитьСтруктуруПредставленияПлательщикаЧека(
        Знач ДокументРегистрацииСсылка, Знач СтрогийРежимКонтроля = Истина, Знач ДобавитьВПредставлениеИНН = Истина) Экспорт

    СтрогийРежимКонтроля = ?(СтрогийРежимКонтроля = Неопределено, Истина, СтрогийРежимКонтроля);

    РезультатФункции = Новый Структура(
            "Успех, Контрагент, ПредставлениеПлательщика, ПринятоОт, СведенияОПокупателе, ТекстСообщения, ЭтоФизЛицо", Истина);

    ДанныеДокументаРегистрации =
        ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДокументРегистрацииСсылка,
            Новый Структура("Контрагент, ЛицевыеСчета, Дата"));
    Если ЗначениеЗаполнено(ДанныеДокументаРегистрации.Контрагент) = Ложь Тогда
        РезультатФункции.Успех = Ложь;
        РезультатФункции.ТекстСообщения = "Контрагент не определен";
        Возврат РезультатФункции; // Контрагент не определен
    КонецЕсли;

    ДанныеДокументаРегистрации.ЛицевыеСчета = ДанныеДокументаРегистрации.ЛицевыеСчета.Выгрузить();

    РезультатФункции.Контрагент = ДанныеДокументаРегистрации.Контрагент;

    РезультатФункции.СведенияОПокупателе = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(
            ДанныеДокументаРегистрации.Контрагент, ДанныеДокументаРегистрации.Дата);
    РезультатФункции.ПредставлениеПлательщика =
        ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(РезультатФункции.СведенияОПокупателе, "НаименованиеДляПечатныхФорм");
    РезультатФункции.ЭтоФизЛицо =
        ГП_РаботаСКонтрагентами.ЭтотКонтрагентФизическоеЛицо(ДанныеДокументаРегистрации.Контрагент);

    // Это юр. лицо
    Если РезультатФункции.ЭтоФизЛицо = Ложь Тогда
        Если ЗначениеЗаполнено(РезультатФункции.СведенияОПокупателе.ИНН) И ДобавитьВПредставлениеИНН = Истина Тогда
            РезультатФункции.ПредставлениеПлательщика =
                СокрЛП(СтрШаблон("%1 ИНН %2", РезультатФункции.ПредставлениеПлательщика, РезультатФункции.СведенияОПокупателе.ИНН));
        КонецЕсли;

        Возврат РезультатФункции;
    КонецЕсли;

    // Получение представления (принято от) из документа оплаты
    ТаблицаДокументовОплатыЛС = ДанныеДокументаРегистрации.ЛицевыеСчета.Скопировать( , "ДокументОплаты");
    ТаблицаДокументовОплатыЛС.Свернуть("ДокументОплаты");

    // Контроль данных таблицы л/с
    Если ТаблицаДокументовОплатыЛС.Количество() = 0 Тогда
        Возврат РезультатФункции;
    КонецЕсли;

    Если ТаблицаДокументовОплатыЛС.Количество() > 1 Тогда
        ТекстСообщения = СтрШаблон(
                "Документы оплат строк л/с документа ""%1"" отличаются", Строка(ДокументРегистрацииСсылка));
        Если СтрогийРежимКонтроля Тогда
            РезультатФункции.Успех = Ложь;
            РезультатФункции.ТекстСообщения = ТекстСообщения;

            Возврат РезультатФункции;
        КонецЕсли;

        ОбщегоНазначения.СообщитьПользователю(ТекстСообщения); // Предупреждение
    КонецЕсли;

    // Формирование представления по полю ПринятоОт
    ОсновнойДокументОплаты = ТаблицаДокументовОплатыЛС[0].ДокументОплаты;
    Если ТипЗнч(ОсновнойДокументОплаты) = Тип("ДокументСсылка.ПриходныйКассовыйОрдер") Тогда
        // Проверка соответствия контрагента
        Если ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ОсновнойДокументОплаты, "Контрагент") <> ДанныеДокументаРегистрации.Контрагент Тогда
            ТекстСообщения = СтрШаблон(
                    "Контрагент документа оплаты не соответствует контрагенту ""%1"" документа реализации",
                    Строка(ДанныеДокументаРегистрации.Контрагент));
            Если СтрогийРежимКонтроля Тогда
                РезультатФункции.Успех = Ложь;
                РезультатФункции.ТекстСообщения = ТекстСообщения;

                Возврат РезультатФункции;
            КонецЕсли;

            ОбщегоНазначения.СообщитьПользователю(ТекстСообщения); // Предупреждение
        КонецЕсли;

        РезультатФункции.ПринятоОт = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ОсновнойДокументОплаты, "ПринятоОт");
        РезультатФункции.ПредставлениеПлательщика = ?(ПустаяСтрока(РезультатФункции.ПринятоОт),
                РезультатФункции.ПредставлениеПлательщика, РезультатФункции.ПринятоОт);
        Если ЗначениеЗаполнено(РезультатФункции.СведенияОПокупателе.ИНН) И ДобавитьВПредставлениеИНН = Истина Тогда
            РезультатФункции.ПредставлениеПлательщика = СокрЛП(СтрШаблон("%1 ИНН %2",
                РезультатФункции.ПредставлениеПлательщика, РезультатФункции.СведенияОПокупателе.ИНН));
        КонецЕсли;
    КонецЕсли;

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  ТекущаяСтрока - Структура, СтрокаТаблицыЗначений
//      * Документ - ДокументСсылка
//  КэшКонтрагентыДокументов - Соответствие
// Возвращаемое значение:
//  - СправочникСсылка.Контрагенты, Неопределено
Функция ЗаполнитьКонтрагентаДокументаСтрокиОплаты(ТекущаяСтрока, КэшКонтрагентыДокументов) Экспорт
    РезультатФункции = Неопределено;

    Если ТипЗнч(ТекущаяСтрока.Документ) = Тип("ДокументСсылка.КВП_РегистрацияОплаты") Тогда
        Если КэшКонтрагентыДокументов.Получить(ТекущаяСтрока.Документ) = Неопределено Тогда
            ТекущийКонтрагентДокументаОплаты = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ТекущаяСтрока.Документ, "Контрагент");
            КэшКонтрагентыДокументов.Вставить(ТекущаяСтрока.Документ, ТекущийКонтрагентДокументаОплаты);
        КонецЕсли;

        ТекущийКонтрагентДокументаОплаты = КэшКонтрагентыДокументов.Получить(ТекущаяСтрока.Документ);
        ТекущаяСтрока.ГП_КонтрагентДокументаОплаты = ТекущийКонтрагентДокументаОплаты;

        РезультатФункции = ТекущийКонтрагентДокументаОплаты;
    КонецЕсли;

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  ИсходнаяТаблица - ТаблицаЗначений
// Возвращаемое значение:
//  - КолонкаТаблицыЗначений, Неопределено - Если колонка уже существует возвращает - Неопределено
Функция ДополнитьТаблицуКолонкойКонтрагентДокументаОплаты(ИсходнаяТаблица) Экспорт
    ИмяКолонкиДобавления = ПолучитьИмяКолонкиКонтрагентДокументаОплаты();

    Если ИсходнаяТаблица.Колонки.Найти(ИмяКолонкиДобавления) = Неопределено Тогда
        Возврат ИсходнаяТаблица.Колонки.Добавить(ИмяКолонкиДобавления, Новый ОписаниеТипов("СправочникСсылка.Контрагенты"));
    КонецЕсли;
КонецФункции

// Параметры:
//  РасшифровкаОплатДляЧеков - ТаблицаЗначений
//  СтруктураПараметров - Структура
//      * ПечататьЧекиСРасшифровкойПоУслугам - Булево
//      * ГП_ФормироватьЧекиЖКХПоКонтрагентуДокумента - Булево
//      * УказыватьВЧекеПризнакАгентаВПлатежах - Булево
// Возвращаемое значение:
//  - Булево - Истина если процесс сворачивания выполнялся
Функция СвернутьТаблицуРасшифровкаОплатДляЧековПоТарифамУслуг(РасшифровкаОплатДляЧеков, Знач СтруктураПараметров) Экспорт
    РезультатФункции = Ложь;

    Если СтруктураПараметров.ПечататьЧекиСРасшифровкойПоУслугам = Ложь Тогда
        Возврат РезультатФункции;
    КонецЕсли;

    КолонкиСворачивания = Новый Массив;
    КолонкиСворачивания.Добавить("Документ");
    КолонкиСворачивания.Добавить("ВидУслугиПредставление");
    КолонкиСворачивания.Добавить("СтавкаНДС");
    КолонкиСворачивания.Добавить("ЭтоПени");
    КолонкиСворачивания.Добавить("ЭтоАванс");
    КолонкиСворачивания.Добавить("ПризнакПредметаРасчета");
    КолонкиСворачивания.Добавить("ПризнакСпособаРасчета");
    // Гарант+ Килипенко 10.03.2025 [F00235125] Печать чеков по контрагенту документа ++
    //
    // КолонкиСворачивания.Добавить("Тариф");
    //
    // Гарант+ Килипенко 10.03.2025 [F00235125] Печать чеков по контрагенту документа --
    // Поле исключено по требованию заказчика
    // КолонкиСворачивания.Добавить("МесяцНачисления");
    КолонкиСворачивания.Добавить("ЭтоДобровольноеСтрахование");
    КолонкиСворачивания.Добавить("УказыватьВЧекеПризнакАгентаВПлатежах");

    КоличествоКолонокИгнорирования = "2";

    Если СтруктураПараметров.ГП_ФормироватьЧекиЖКХПоКонтрагентуДокумента = Истина Тогда
        КолонкиСворачивания.Добавить("ГП_КонтрагентДокументаОплаты");
    Иначе
        КолонкиСворачивания.Добавить("ЛицевойСчет");
    КонецЕсли;

    Если СтруктураПараметров.УказыватьВЧекеПризнакАгентаВПлатежах = Истина Тогда
        КолонкиСворачивания.Добавить("ПоставщикУслугиПредставление");
        КолонкиСворачивания.Добавить("ИННПоставщикаУслуги");
        КолонкиСворачивания.Добавить("ТелефонПоставщикаУслуги");
    КонецЕсли;

    СтрокаКолонокСворачивания = "";
    Для Каждого ТекущаяКолонкаСворачивания Из КолонкиСворачивания Цикл
        // Контроль наличия колонки
        Если РасшифровкаОплатДляЧеков.Колонки.Найти(ТекущаяКолонкаСворачивания) = Неопределено Тогда
            ОбщегоНазначения.СообщитьПользователю(
                "ВНИМАНИЕ! В таблице сворачивания отсутствует колонка группировки ""%1""", ТекущаяКолонкаСворачивания);
        КонецЕсли;

        СтрокаКолонокСворачивания = СтрШаблон("%1,%2", СтрокаКолонокСворачивания, ТекущаяКолонкаСворачивания);
    КонецЦикла;
    Если СтрДлина(СтрокаКолонокСворачивания) > 0 Тогда
        СтрокаКолонокСворачивания = Сред(СтрокаКолонокСворачивания, 2);
    КонецЕсли;

    КолонкиСуммирования = Новый Массив;
    КолонкиСуммирования.Добавить("Сумма");
    // Гарант+ Килипенко 03.04.2025 [F00237121] Обновление 3_0_172_1 ++ {
    КолонкиСуммирования.Добавить("СуммаНДС");
    // Гарант+ Килипенко 03.04.2025 [F00237121] Обновление 3_0_172_1 -- }

    СтрокаКолонокСуммирования = "";
    Для Каждого ТекущаяКолонкаСуммирования Из КолонкиСуммирования Цикл
        // Контроль наличия колонки
        Если РасшифровкаОплатДляЧеков.Колонки.Найти(ТекущаяКолонкаСуммирования) = Неопределено Тогда
            ОбщегоНазначения.СообщитьПользователю(
                "ВНИМАНИЕ! В таблице сворачивания отсутствует колонка суммирования ""%1""", ТекущаяКолонкаСуммирования);
        КонецЕсли;

        СтрокаКолонокСуммирования = СтрШаблон("%1,%2", СтрокаКолонокСуммирования, ТекущаяКолонкаСуммирования);
    КонецЦикла;
    Если СтрДлина(СтрокаКолонокСворачивания) > 0 Тогда
        СтрокаКолонокСуммирования = Сред(СтрокаКолонокСуммирования, 2);
    КонецЕсли;

    // Контроль колонок
    Если (КолонкиСворачивания.Количество() + 1 + КолонкиСуммирования.Количество())
            <> (РасшифровкаОплатДляЧеков.Колонки.Количество() - КоличествоКолонокИгнорирования) Тогда
        ОбщегоНазначения.СообщитьПользователю(
            "ВНИМАНИЕ! Информация для разработчика: Количество колонок исходной"
            + " таблицы для сворачивания по тарифу услуг не соответствует ожиданию");
    КонецЕсли;

    РасшифровкаОплатДляЧеков.Свернуть(СтрокаКолонокСворачивания, СтрокаКолонокСуммирования);

    // Гарант+ Килипенко 10.03.2025 [F00235125] Печать чеков по контрагенту документа ++
    // Сброс тарифов
    РасшифровкаОплатДляЧеков.Колонки.Добавить("Тариф", Новый ОписаниеТипов("Число"));
    Для Каждого ТекущаяСтрокаРасшифровки Из РасшифровкаОплатДляЧеков Цикл
    	ТекущаяСтрокаРасшифровки.Тариф = ТекущаяСтрокаРасшифровки.Сумма;
    КонецЦикла;
    // Гарант+ Килипенко 10.03.2025 [F00235125] Печать чеков по контрагенту документа --

    Возврат Истина;
КонецФункции

#Область Константы

// Параметры:
//  СписокУслуг - СписокЗначений, Массив из СправочникСсылка.КВП_Услуги
// Возвращаемое значение:
//  - Структура
//      * РаспределятьПоУказаннымУслугам - Булево
//      * ФлагРедактирования - Булево
//      * ФлагРедактированияНастроек - Число
//      * ВариантРаспределения - Строка
//      * НастройкиОплатыОбъекта - ТаблицаЗначений
Функция НовыйПредопределенныеНастройкиРаспределенияПоСпискуУслуг(Знач СписокУслуг = Неопределено) Экспорт
    СписокУслуг = ?(СписокУслуг = Неопределено, Новый СписокЗначений, СписокУслуг);

    РезультатФункции = НовыйНастройкиРаспределения();
    РезультатФункции.РаспределятьПоУказаннымУслугам = Истина;
    РезультатФункции.ФлагРедактирования = Ложь;
    РезультатФункции.ФлагРедактированияНастроек = 1;
    РезультатФункции.ВариантРаспределения = "ПоУслугам";

    РезультатФункции.Вставить("НастройкиОплатыОбъекта", НовыйТаблицаНастройкиОплатыОбъекта());

    Для Каждого ЭлементУслуг Из СписокУслуг Цикл
        НоваяСтрокаНастроекОплаты = РезультатФункции.НастройкиОплатыОбъекта.Добавить();

        ЗначениеТекущейУслуги = ?(ТипЗнч(СписокУслуг) = Тип("СписокЗначений"), ЭлементУслуг.Значение, ЭлементУслуг);
        НоваяСтрокаНастроекОплаты.Параметр = ЗначениеТекущейУслуги;
        НоваяСтрокаНастроекОплаты.Использовать = Истина;
    КонецЦикла;

    Возврат РезультатФункции;
КонецФункции

// Возвращаемое значение:
//  - Структура
//      * РаспределятьПоУказаннымУслугам - Булево
//      * ФлагРедактирования - Булево
//      * ФлагРедактированияНастроек - Число
//      * ВариантРаспределения - Строка
//      * НастройкиОплатыОбъекта - ТаблицаЗначений
Функция НовыйНастройкиРаспределения() Экспорт
    РезультатФункции = Новый Структура;
    РезультатФункции.Вставить("РаспределятьПоУказаннымУслугам", Ложь);
    РезультатФункции.Вставить("ФлагРедактирования", Ложь);
    РезультатФункции.Вставить("ФлагРедактированияНастроек", 0);
    РезультатФункции.Вставить("ВариантРаспределения", "");
    РезультатФункции.Вставить("НастройкиОплатыОбъекта", НовыйТаблицаНастройкиОплатыОбъекта());

    Возврат РезультатФункции;
КонецФункции

// Возвращаемое значение:
//  - ТаблицаЗначений - Документы.КВП_РегистрацияОплаты.НастройкиОплаты
Функция НовыйТаблицаНастройкиОплатыОбъекта() Экспорт
    РезультатФункции = Документы.КВП_РегистрацияОплаты.СоздатьДокумент().НастройкиОплаты.ВыгрузитьКолонки();
    Возврат РезультатФункции;
КонецФункции

// Возвращаемое значение:
//  - СписокЗначений из СправочникСсылка.КВП_Услуги
Функция ПолучитьСписокУслугПоУмолчаниюДляРаспределения() Экспорт
    РезультатФункции = Новый СписокЗначений;
    РезультатФункции.Добавить(ГП_РаботаСУслугами.ПолучитьУслугуХолодноеВодоснабжение().Ссылка);
    РезультатФункции.Добавить(ГП_РаботаСУслугами.ПолучитьУслугуКанализации().Ссылка);

    Возврат РезультатФункции;
КонецФункции

// Возвращаемое значение:
//  - Массив из Структура
Функция ПолучитьУслугиДляИгнорированияПриРаспределенииАванса() Экспорт
    УслугиДляИгнорирования = Новый Массив();

    Попытка
        УслугиДляИгнорирования.Добавить(ГП_РаботаСУслугами.ПолучитьУслугуГорячееВодоснабжение()); // ГВС
        УслугиДляИгнорирования.Добавить(ГП_РаботаСУслугами.ПолучитьУслугуНегативногоВоздействияНаЦСВ()); // Негативное воздействие
    Исключение
        ОбщегоНазначения.СообщитьПользователю(СтрШаблон(
                "ВНИМАНИЕ! Услуги для игнорирования при распределении авансов не найдены"));
    КонецПопытки;

    Возврат УслугиДляИгнорирования;
КонецФункции

// Возвращаемое значение:
//  - Строка
Функция ПолучитьИмяКолонкиКонтрагентДокументаОплаты() Экспорт
    Возврат "ГП_КонтрагентДокументаОплаты";
КонецФункции

#КонецОбласти // Константы

#КонецОбласти // СлужебныйПрограммныйИнтерфейс
// Гарант+ Килипенко 01.11.2024 [F00230427] Создание регистрации оплаты на основании поступления --
