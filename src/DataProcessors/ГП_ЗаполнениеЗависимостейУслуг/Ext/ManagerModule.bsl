﻿// Гарант+ Килипенко 24.07.2024 [F00226318] заполнение регистра сведений Зависимость услуг ++
#Область ПрограммныйИнтерфейс

// Выполняет запись (обновление) зависимостей услуг в регистр сведений "Зависимости услуг".
// Параметры:
//  Период - Дата, Неопределено - Дата (начало месяца), по умолчанию 01.01.2024г
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * КоличествоЗаписейЗависимыхУслуг - Число
//      * СообщениеОбОшибке - Строка, Неопределено
Функция ЗаполнитьЗависимостиУслуг(Знач Период = Неопределено) Экспорт
    РезультатФункции = Новый Структура("Успех, КоличествоЗаписейЗависимыхУслуг, СообщениеОбОшибке", Истина, 0);

    РезультатПолученияДанных = ПолучитьДанныеЗависимостейУслугАбонентов();
    Если РезультатПолученияДанных.Успех = Ложь Тогда
        РезультатФункции.Успех = Ложь;
        Возврат РезультатФункции;
    КонецЕсли;

    ТаблицаСоответствийКодовУслуг = ПолучитьСоответствиеКВПУслуг();

    // Значения по умолчанию
    ЗависимаяУслуга = ТаблицаСоответствийКодовУслуг["00-008"]; // Канализация
    ОсновнаяОрганизацияСсылка = УПЖКХ_ТиповыеМетодыВызовСервера.ПолучитьОсновнуюОрганизацию();
    Если Период = Неопределено Тогда
        Период = Дата(2024, 01, 01); // По ТЗ дата по умолчанию 01.01.2024г.
    Иначе
        Период = НачалоМесяца(Период);
    КонецЕсли;

    СписокОсновныхУслуг = Новый Массив;
    СписокОсновныхУслуг.Добавить("ХолоднаяВода");
    СписокОсновныхУслуг.Добавить("ГорячаяВода");
    СписокОсновныхУслуг.Добавить("ХолоднаяВодаВодоотвод");

    НачатьТранзакцию();
    Попытка
        Для Каждого КлючУслуги Из СписокОсновныхУслуг Цикл
            Для Каждого СтрокаУслуги Из РезультатПолученияДанных[КлючУслуги] Цикл
                ОсновнаяУслуга = ТаблицаСоответствийКодовУслуг[СтрокаУслуги.КодУслуги];
                НовыйНаборЗаписей = СоздатьНаборЗаписейЗависимостиУслуг(
                        Период, СтрокаУслуги.Здание, ОсновнаяУслуга, ЗависимаяУслуга, ОсновнаяОрганизацияСсылка);

                НоваяЗапись = НовыйНаборЗаписей.Добавить();
                НоваяЗапись.Период = Период;
                НоваяЗапись.Объект = СтрокаУслуги.Здание;
                НоваяЗапись.УслугаОснование = ОсновнаяУслуга;
                НоваяЗапись.Услуга = ЗависимаяУслуга;
                НоваяЗапись.Организация = ОсновнаяОрганизацияСсылка;
                НоваяЗапись.Действует = Истина; // По ТЗ всегда Истина
                НоваяЗапись.Значение = 100.0;   // Исправлено (числ/знам)
                НоваяЗапись.ЗначениеОснование = СтрокаУслуги.Процент;

                НовыйНаборЗаписей.Записать(Истина);
                РезультатФункции.КоличествоЗаписейЗависимыхУслуг = РезультатФункции.КоличествоЗаписейЗависимыхУслуг + 1;
            КонецЦикла;
        КонецЦикла;

        ЗафиксироватьТранзакцию(); // Записано успешно

    Исключение
        ОтменитьТранзакцию();

        ЖурналРегистрации.ДобавитьСообщениеДляЖурналаРегистрации(
            "Ошибка при записи зависимостей услуг в регистр ""КВП_ЗависимостиУслуг"".",
            УровеньЖурналаРегистрации.Ошибка, , ,
            ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));

        РезультатФункции.КоличествоЗаписейЗависимыхУслуг = 0;
        РезультатФункции.СообщениеОбОшибке = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
        РезультатФункции.Успех = Ложь;
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 02.10.2024 [F00229273] заполнение регистра сведений Зависимость услуг по НВ на ЦСВ ++
//
// Выполняет запись (обновление) зависимостей услуг по негативному воздействию в регистр сведений "Зависимости услуг".
// Параметры:
//  Период - Дата, Неопределено - Дата (начало месяца), по умолчанию 01.01.2024г
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * КоличествоЗаписейЗависимыхУслуг - Число
//      * СообщениеОбОшибке - Строка, Неопределено
Функция ЗаполнитьЗависимостиУслугДляНегативногоВоздействия(Знач Период = Неопределено) Экспорт
    РезультатФункции = Новый Структура("Успех, КоличествоЗаписейЗависимыхУслуг, СообщениеОбОшибке", Истина, 0);

    РезультатПолученияДанных = ПолучитьДанныеЗависимостейУслугАбонентовДляНегативногоВоздействия();

    ТаблицаСоответствийКодовУслуг = ПолучитьСоответствиеКВПУслуг();

    // Значения по умолчанию
    ЗависимаяУслуга = ТаблицаСоответствийКодовУслуг["00-006"]; // Негативное воздействие
    ОсновнаяОрганизацияСсылка = УПЖКХ_ТиповыеМетодыВызовСервера.ПолучитьОсновнуюОрганизацию();
    Если Период = Неопределено Тогда
        Период = Дата(2024, 01, 01); // По ТЗ дата по умолчанию 01.01.2024г.
    Иначе
        Период = НачалоМесяца(Период);
    КонецЕсли;

    // По умолчанию устанавливаем НГ как зависимую для ХВС и ГВС
    СписокОсновныхУслуг = Новый Массив;
    СписокОсновныхУслуг.Добавить("00-001"); // ХВС
    СписокОсновныхУслуг.Добавить("00-003"); // ГВС

    НачатьТранзакцию();
    Попытка
        Для Каждого КлючУслуги Из СписокОсновныхУслуг Цикл
            Для Каждого СтрокаУслуги Из РезультатПолученияДанных Цикл
                ОсновнаяУслуга = ТаблицаСоответствийКодовУслуг[КлючУслуги];
                НовыйНаборЗаписей = СоздатьНаборЗаписейЗависимостиУслуг(
                        Период, СтрокаУслуги.Здание, ОсновнаяУслуга, ЗависимаяУслуга, ОсновнаяОрганизацияСсылка);

                НоваяЗапись = НовыйНаборЗаписей.Добавить();
                НоваяЗапись.Период = Период;
                НоваяЗапись.Объект = СтрокаУслуги.Здание;
                НоваяЗапись.УслугаОснование = ОсновнаяУслуга;
                НоваяЗапись.Услуга = ЗависимаяУслуга;
                НоваяЗапись.Организация = ОсновнаяОрганизацияСсылка;
                НоваяЗапись.Действует = Истина; // По ТЗ всегда Истина
                НоваяЗапись.Значение = 100.0;   // Исправлено (числ/знам)
                НоваяЗапись.ЗначениеОснование = ?(КлючУслуги = "00-001", СтрокаУслуги.ПроцентХВ, СтрокаУслуги.ПроцентГВ);

                НовыйНаборЗаписей.Записать(Истина);
                РезультатФункции.КоличествоЗаписейЗависимыхУслуг = РезультатФункции.КоличествоЗаписейЗависимыхУслуг + 1;
            КонецЦикла;
        КонецЦикла;

        ЗафиксироватьТранзакцию(); // Записано успешно

    Исключение
        ОтменитьТранзакцию();

        ЖурналРегистрации.ДобавитьСообщениеДляЖурналаРегистрации(
            "Ошибка при записи зависимостей услуг в регистр ""КВП_ЗависимостиУслуг"".",
            УровеньЖурналаРегистрации.Ошибка, , ,
            ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));

        РезультатФункции.КоличествоЗаписейЗависимыхУслуг = 0;
        РезультатФункции.СообщениеОбОшибке = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
        РезультатФункции.Успех = Ложь;
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 02.10.2024 [F00229273] заполнение регистра сведений Зависимость услуг по НВ на ЦСВ --

#КонецОбласти // ПрограммныйИнтерфейс
// Гарант+ Килипенко 24.07.2024 [F00226318] заполнение регистра сведений Зависимость услуг --

// Гарант+ Килипенко 24.07.2024 [F00226318] заполнение регистра сведений Зависимость услуг ++
#Область СлужебныеПроцедурыИФункции

// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * ХолоднаяВода - ТаблицаЗначений, Неопределено
//      * ГорячаяВода - ТаблицаЗначений, Неопределено
//      * Канализация - ТаблицаЗначений, Неопределено
//      * ХолоднаяВодаВодоотвод - ТаблицаЗначений, Неопределено
//          ** ОбъектАбонентаКод - Строка
//          ** КонтрагентКод - Строка
//          ** ЛицевойСчет - СправочникСсылка.КВП_ЛицевыеСчета
//          ** Здание - СправочникСсылка.КВП_Здания
//          ** Процент - Число - Процент использования В %
//          ** ЭтоХолоднаяВода - Булево
//          ** КодУслуги - Строка
Функция ПолучитьДанныеЗависимостейУслугАбонентов()
    РезультатФункции = Новый Структура(
            "Успех, ХолоднаяВода, ГорячаяВода, ХолоднаяВодаВодоотвод", Истина);

    Запрос = Новый Запрос;
    #Область ТекстЗапроса
    Запрос.Текст =
        "////////////////////////////////////////////////////////////////////////////////
        |// Сбор данных объектов абонентов из регистра ГП_УслугиБП77
        |//
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
        |	ГП_УслугиБП77.ОбъектАбонентаКод КАК ОбъектАбонентаКод,
        |	ГП_УслугиБП77.КонтрагентКод КАК КонтрагентКод,
        |	ГП_УслугиБП77.ЛицевойСчет КАК ЛицевойСчет,
        |	ГП_УслугиБП77.ТолькоДляКанализации КАК ТолькоДляКанализации,
        |	ГП_УслугиБП77.МетодРасчетаХВ КАК МетодРасчетаХВ,
        |	ГП_УслугиБП77.МетодРасчетаГВ КАК МетодРасчетаГВ,
        |	ГП_УслугиБП77.МетодРасчетаКан КАК МетодРасчетаКан,
        |	ГП_УслугиБП77.ПроцентХВ КАК ПроцентХВ,
        |	ГП_УслугиБП77.ПроцентГВ КАК ПроцентГВ
        |ПОМЕСТИТЬ ВТ_ОбъектыАбонентовПодготовка
        |ИЗ
        |	РегистрСведений.ГП_УслугиБП77 КАК ГП_УслугиБП77
        |ГДЕ
        |   ГП_УслугиБП77.ЛицевойСчет <> &ПустаяСсылкаЛС
        |   И ГП_УслугиБП77.МетодРасчетаКан <> ""Нет""
        |   И (ГП_УслугиБП77.ПроцентХВ > 0 ИЛИ ГП_УслугиБП77.ПроцентГВ > 0)
        |	И (ГП_УслугиБП77.МетодРасчетаХВ <> ""Нет"" ИЛИ ГП_УслугиБП77.МетодРасчетаГВ <> ""Нет"")
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |// Результат [1] - Холодная вода
        |ВЫБРАТЬ
        |	ВТ_ОбъектыАбонентовПодготовка.ОбъектАбонентаКод КАК ОбъектАбонентаКод,
        |	ВТ_ОбъектыАбонентовПодготовка.КонтрагентКод КАК КонтрагентКод,
        |	ВТ_ОбъектыАбонентовПодготовка.ЛицевойСчет КАК ЛицевойСчет,
        |	ВТ_ОбъектыАбонентовПодготовка.ЛицевойСчет.Адрес.Владелец КАК Здание,
        |	ВТ_ОбъектыАбонентовПодготовка.ПроцентХВ КАК Процент,
        |	""00-001"" КАК КодУслуги
        |ИЗ
        |   ВТ_ОбъектыАбонентовПодготовка КАК ВТ_ОбъектыАбонентовПодготовка
        |ГДЕ
        |   ВТ_ОбъектыАбонентовПодготовка.МетодРасчетаХВ <> ""Нет""
        |   И ВТ_ОбъектыАбонентовПодготовка.ТолькоДляКанализации = ЛОЖЬ
        |   И ВТ_ОбъектыАбонентовПодготовка.ПроцентХВ > 0
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |// Результат [2] - Холодная вода (водоотвод)
        |ВЫБРАТЬ
        |	ВТ_ОбъектыАбонентовПодготовка.ОбъектАбонентаКод КАК ОбъектАбонентаКод,
        |	ВТ_ОбъектыАбонентовПодготовка.КонтрагентКод КАК КонтрагентКод,
        |	ВТ_ОбъектыАбонентовПодготовка.ЛицевойСчет КАК ЛицевойСчет,
        |	ВТ_ОбъектыАбонентовПодготовка.ЛицевойСчет.Адрес.Владелец КАК Здание,
        |	ВТ_ОбъектыАбонентовПодготовка.ПроцентХВ КАК Процент,
        |	""00-005"" КАК КодУслуги
        |ИЗ
        |   ВТ_ОбъектыАбонентовПодготовка КАК ВТ_ОбъектыАбонентовПодготовка
        |ГДЕ
        |   ВТ_ОбъектыАбонентовПодготовка.МетодРасчетаХВ <> ""Нет""
        |   И ВТ_ОбъектыАбонентовПодготовка.ТолькоДляКанализации = ИСТИНА
        |   И ВТ_ОбъектыАбонентовПодготовка.ПроцентХВ > 0
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |// Результат [3] - Горячая вода
        |ВЫБРАТЬ
        |	ВТ_ОбъектыАбонентовПодготовка.ОбъектАбонентаКод КАК ОбъектАбонентаКод,
        |	ВТ_ОбъектыАбонентовПодготовка.КонтрагентКод КАК КонтрагентКод,
        |	ВТ_ОбъектыАбонентовПодготовка.ЛицевойСчет КАК ЛицевойСчет,
        |	ВТ_ОбъектыАбонентовПодготовка.ЛицевойСчет.Адрес.Владелец КАК Здание,
        |	ВТ_ОбъектыАбонентовПодготовка.ПроцентГВ КАК Процент,
        |	""00-003"" КАК КодУслуги
        |ИЗ
        |   ВТ_ОбъектыАбонентовПодготовка КАК ВТ_ОбъектыАбонентовПодготовка
        |ГДЕ
        |   ВТ_ОбъектыАбонентовПодготовка.МетодРасчетаГВ <> ""Нет""
        |   И ВТ_ОбъектыАбонентовПодготовка.ПроцентГВ > 0
        |;";

    #КонецОбласти // ТекстЗапроса

    Запрос.УстановитьПараметр("ПустаяСсылкаЛС", Справочники.КВП_ЛицевыеСчета.ПустаяСсылка());

    ТаблицыПакета = Запрос.ВыполнитьПакет();
    РезультатФункции.ХолоднаяВода = ТаблицыПакета[1].Выгрузить();
    РезультатФункции.ГорячаяВода = ТаблицыПакета[2].Выгрузить();
    РезультатФункции.ХолоднаяВодаВодоотвод = ТаблицыПакета[3].Выгрузить();

    РезультатФункции.Успех = (РезультатФункции.ХолоднаяВода.Количество()
            + РезультатФункции.ГорячаяВода.Количество()
            + РезультатФункции.ХолоднаяВодаВодоотвод.Количество()) > 0;

    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 02.10.2024 [F00229273] заполнение регистра сведений Зависимость услуг по НВ на ЦСВ ++
//
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * ЛицевойСчет
//      * Помещение
//      * Здание
//      * ПроцентХВ
//      * ПроцентГВ
//      * НеНачислять
Функция ПолучитьДанныеЗависимостейУслугАбонентовДляНегативногоВоздействия()
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ГП_ЗданияБП77.КонтрагентКод КАК КонтрагентКод,
        |	ГП_ЗданияБП77.ОбъектАбонентаКод КАК ОбъектАбонентаКод,
        |	ГП_ЗданияБП77.Здание КАК Здание,
        |	ГП_ЗданияБП77.ОбъектАбонентаНаименование КАК ОбъектАбонентаНаименование,
        |	ГП_ЗданияБП77.ТолькоДляКанализации КАК ТолькоДляКанализации,
        |	ГП_ЗданияБП77.ПроцентХВ КАК ПроцентХВ,
        |	ГП_ЗданияБП77.ПроцентГВ КАК ПроцентГВ,
        |	ГП_ЗданияБП77.НаПодогрев КАК НаПодогрев,
        |	ГП_ЗданияБП77.НеНачислять КАК НеНачислять,
        |	ГП_КонтрагентыБП77.Контрагент КАК КонтрагентНаименование
        |ПОМЕСТИТЬ ВТ_ЗданияНГБП77
        |ИЗ
        |	РегистрСведений.ГП_ЗданияБП77 КАК ГП_ЗданияБП77
        |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ГП_КонтрагентыБП77 КАК ГП_КонтрагентыБП77
        |		ПО ГП_ЗданияБП77.КонтрагентКод = ГП_КонтрагентыБП77.Код
        |ГДЕ
        |	ГП_ЗданияБП77.ЭтоНегативноеВоздействиеЦСВ = ИСТИНА
        |	И ГП_ЗданияБП77.ЭтоПлатаЗаХолодноеВодоснабжениеОИ = ЛОЖЬ
        |	И НЕ ГП_КонтрагентыБП77.Код ЕСТЬ NULL
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ГП_ЗданияБП77.КонтрагентКод КАК КонтрагентКод,
        |	ГП_ЗданияБП77.ОбъектАбонентаКод КАК ОбъектАбонентаКод,
        |	ГП_ЗданияБП77.ОбъектАбонентаКод + ""_"" + ГП_ЗданияБП77.КонтрагентКод КАК Идентификатор,
        |	ГП_ЗданияБП77.Здание КАК Здание,
        |	ГП_ЗданияБП77.ОбъектАбонентаНаименование КАК ОбъектАбонентаНаименование,
        |	ГП_ЗданияБП77.ТолькоДляКанализации КАК ТолькоДляКанализации,
        |	ВТ_ЗданияНГБП77.ПроцентХВ КАК ПроцентХВ,
        |	ВТ_ЗданияНГБП77.ПроцентГВ КАК ПроцентГВ,
        |	ВТ_ЗданияНГБП77.НаПодогрев КАК НаПодогрев,
        |	ВТ_ЗданияНГБП77.НеНачислять КАК НеНачислять
        |ПОМЕСТИТЬ ВТ_ЗданияБП77ДляНГ
        |ИЗ
        |	ВТ_ЗданияНГБП77 КАК ВТ_ЗданияНГБП77
        |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ГП_ЗданияБП77 КАК ГП_ЗданияБП77
        |		ПО (ГП_ЗданияБП77.КонтрагентКод = ВТ_ЗданияНГБП77.КонтрагентКод)
        |			И (ГП_ЗданияБП77.ОбъектАбонентаНаименование <> ВТ_ЗданияНГБП77.ОбъектАбонентаНаименование)
        |			// И ГП_ЗданияБП77.ТолькоДляКанализации = ЛОЖЬ // !!! УТОЧНИТЬ
        |			И (ВТ_ЗданияНГБП77.ОбъектАбонентаНаименование ПОДОБНО ГП_ЗданияБП77.ОбъектАбонентаНаименование + "" [(]"" + &ШаблонНегативногоВоздействия
        |				ИЛИ ВТ_ЗданияНГБП77.ОбъектАбонентаНаименование ПОДОБНО ""(негативное%воздействие%)""
        |				ИЛИ ВТ_ЗданияНГБП77.ОбъектАбонентаНаименование ПОДОБНО ГП_ЗданияБП77.ОбъектАбонентаНаименование + "" [(] "" + &ШаблонНегативногоВоздействия
        |				ИЛИ ВТ_ЗданияНГБП77.ОбъектАбонентаНаименование ПОДОБНО ГП_ЗданияБП77.ОбъектАбонентаНаименование + ""   [(]"" + &ШаблонНегативногоВоздействия
        |				ИЛИ ВТ_ЗданияНГБП77.ОбъектАбонентаНаименование ПОДОБНО ГП_ЗданияБП77.ОбъектАбонентаНаименование + ""  [(]"" + &ШаблонНегативногоВоздействия)
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	КВП_ЛицевыеСчета.Ссылка КАК ЛицевойСчет,
        |	КВП_ЛицевыеСчета.Ссылка.Адрес КАК Помещение,
        |	КВП_ЛицевыеСчета.Ссылка.Адрес.Владелец КАК Здание,
        |	КВП_ЛицевыеСчета.Идентификатор КАК Идентификатор
        |ПОМЕСТИТЬ ВТ_ЛицевыеСчетаДляУстановкиНГ
        |ИЗ
        |	Справочник.КВП_ЛицевыеСчета КАК КВП_ЛицевыеСчета
        |ГДЕ
        |	КВП_ЛицевыеСчета.ПометкаУдаления = ЛОЖЬ
        |	И КВП_ЛицевыеСчета.ЭтоГруппа = ЛОЖЬ
        |	И Идентификатор В (
        |		ВЫБРАТЬ Идентификатор ИЗ ВТ_ЗданияБП77ДляНГ
        |	)
        |;
        |
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ВТ_ЛицевыеСчетаДляУстановкиНГ.ЛицевойСчет КАК ЛицевойСчет,
        |	ВТ_ЛицевыеСчетаДляУстановкиНГ.Помещение КАК Помещение,
        |	ВТ_ЛицевыеСчетаДляУстановкиНГ.Здание КАК Здание,
        |	ВТ_ЛицевыеСчетаДляУстановкиНГ.Идентификатор КАК Идентификатор,
        |	ВТ_ЗданияБП77ДляНГ.ПроцентХВ КАК ПроцентХВ,
        |	ВТ_ЗданияБП77ДляНГ.ПроцентГВ КАК ПроцентГВ,
        |	ВТ_ЗданияБП77ДляНГ.НаПодогрев КАК НаПодогрев,
        |	ВТ_ЗданияБП77ДляНГ.НеНачислять КАК НеНачислять
        |ИЗ
        |	ВТ_ЛицевыеСчетаДляУстановкиНГ КАК ВТ_ЛицевыеСчетаДляУстановкиНГ
        |	ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ЗданияБП77ДляНГ КАК ВТ_ЗданияБП77ДляНГ
        |	ПО ВТ_ЛицевыеСчетаДляУстановкиНГ.Идентификатор = ВТ_ЗданияБП77ДляНГ.Идентификатор
        |";
    УдалитьИсправленияОшибкиРедактора = "))))"; // ~~~ Только для исправления проблемы редактора ~~~

    Запрос.УстановитьПараметр("ШаблонНегативногоВоздействия", "негатив%возд%");

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();

    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 02.10.2024 [F00229273] заполнение регистра сведений Зависимость услуг по НВ на ЦСВ --

// Устарела. Использовать ГП_МиграцияУслуг.СоздатьНаборЗаписейЗависимостиУслуг
// Параметры:
//  Период - Дата
//  Объект - СправочникСсылка.КВП_Здания
//  УслугаОснованиеСсылка - СправочникСсылка.КВП_Услуги
//  ЗависимаяУслугаСсылка - СправочникСсылка.КВП_Услуги
//  ОрганизацияСсылка - СправочникСсылка.Организации, Неопределено
// Возвращаемое значение:
//  - РегистрСведений.ГП_СчетчикиБП77.НаборЗаписей
Функция СоздатьНаборЗаписейЗависимостиУслуг(
        Знач Период, Знач Объект, Знач УслугаОснованиеСсылка,
        Знач ЗависимаяУслугаСсылка = Неопределено, Знач ОрганизацияСсылка = Неопределено)

    Возврат ГП_МиграцияУслуг.СоздатьНаборЗаписейЗависимостиУслуг(
        Период, Объект, УслугаОснованиеСсылка, ЗависимаяУслугаСсылка, ОрганизацияСсылка);
КонецФункции

// Возвращаемое значение:
//  - Соответствие, Неопределено
Функция ПолучитьСоответствиеКВПУслуг()
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ
        |   КВП_Услуги.Ссылка КАК Ссылка,
        |   КВП_Услуги.Код КАК Код
        |ИЗ
        |   Справочник.КВП_Услуги КАК КВП_Услуги
        |ГДЕ
        |   КВП_Услуги.Код В (&КодыУслуг)
        |";

    МассивКодовУслуг = Новый Массив;
    МассивКодовУслуг.Добавить("00-001");
    МассивКодовУслуг.Добавить("00-002");
    МассивКодовУслуг.Добавить("00-003");
    МассивКодовУслуг.Добавить("00-004");
    МассивКодовУслуг.Добавить("00-005");
    МассивКодовУслуг.Добавить("00-006");
    МассивКодовУслуг.Добавить("00-008");

    Запрос.УстановитьПараметр("КодыУслуг", МассивКодовУслуг);

    РезультатЗапроса = Запрос.Выполнить();
    Если РезультатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    ТаблицаКВПУслуг = РезультатЗапроса.Выгрузить();

    РезультатФункции = Новый Соответствие;
    Для Каждого СтрокаУслуг Из ТаблицаКВПУслуг Цикл
        РезультатФункции.Вставить(СтрокаУслуг.Код, СтрокаУслуг.Ссылка);
    КонецЦикла;

    Возврат РезультатФункции;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
// Гарант+ Килипенко 24.07.2024 [F00226318] заполнение регистра сведений Зависимость услуг --
