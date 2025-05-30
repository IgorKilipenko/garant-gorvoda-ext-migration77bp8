﻿#Область ПрограммныйИнтерфейс

// Получает таблицу договоров с расшифровкой номера договора из наименования
// Параметры:
//  СписокВидовДоговоров - Неопределено, Массив, СписокЗначений из СправочникСсылка.lc_ВидыДоговоров
// Возвращает таблицу соответствий номеров договоров (!!! Только Абонентский отдел) полученных из наименования договора
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Ссылка - СправочникСсылка.ДоговорыКонтрагентов
//      * Наименование - Строка
//      * НомерИзНаименования - Строка
Функция ПолучитьТаблицуСоответствийНомеровНаименованийДоговоров(Знач СписокВидовДоговоров = Неопределено) Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ДоговорыКонтрагентов.Ссылка КАК Ссылка,
        |	ДоговорыКонтрагентов.Наименование КАК Наименование,
        |	ВЫРАЗИТЬ("""" КАК СТРОКА(15)) КАК НомерИзНаименования
        |ИЗ
        |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
        |ГДЕ
        |	ДоговорыКонтрагентов.ЭтоГруппа = ЛОЖЬ
        |	И ДоговорыКонтрагентов.ПометкаУдаления = ЛОЖЬ
        |	И ДоговорыКонтрагентов.lc_ВидДоговора В (&ВидыДоговора)
        |	И ДоговорыКонтрагентов.Владелец ССЫЛКА Справочник.Контрагенты
        |";

    Если СписокВидовДоговоров = Неопределено Тогда
        СписокВидовДоговоров = Новый Массив;
        СписокВидовДоговоров.Добавить(ПолучитьДополнительныйВидДоговораАбонентскийОтдел().Ссылка);
    КонецЕсли;

    Запрос.УстановитьПараметр("ВидыДоговора", СписокВидовДоговоров);

    РезультатЗапроса = Запрос.Выполнить();
    СоответствияНомеровСуществующихДоговоров = РезультатЗапроса.Выгрузить();
    Для Каждого СтрокаДанных Из СоответствияНомеровСуществующихДоговоров Цикл
        // Заполнение поля НомерИзНаименования
        СтруктураНомера = ГП_МиграцияОбщегоНазначения.ПолучитьНомерДоговораПоНаименованию(СтрокаДанных.Наименование);
        Если СтруктураНомера.Успех = Истина Тогда
            СтрокаДанных.НомерИзНаименования = СтруктураНомера.Номер + ?(ПустаяСтрока(СтруктураНомера.Суффикс),
                    "", СтрШаблон("-%1", СтруктураНомера.Суффикс));
        КонецЕсли;
    КонецЦикла;

    Возврат СоответствияНомеровСуществующихДоговоров;
КонецФункции

// Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров ++
//
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Ссылка - СправочникСсылка.ДоговорыКонтрагентов
//      * Наименование - Строка
//      * Номер - Строка
//      * Контрагент - СправочникСсылка.Контрагенты
Функция ПолучитьВсеДоговорыАбонентскогоОтдела() Экспорт
    СписокВидовДоговоров = Новый Массив;
    СписокВидовДоговоров.Добавить(ПолучитьДополнительныйВидДоговораАбонентскийОтдел().Ссылка);

    РезультатФункции = ПолучитьВсеДоговорыПоДополнительномуВиду(СписокВидовДоговоров);

    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров --

// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Ссылка - СправочникСсылка.ДоговорыКонтрагентов
//      * Наименование - Строка
//      * Номер - Строка
//      * Контрагент - СправочникСсылка.Контрагенты
Функция ПолучитьВсеДоговорыНегативногоВоздействия() Экспорт
    СписокВидовДоговоров = Новый Массив;
    СписокВидовДоговоров.Добавить(ПолучитьДополнительныйВидДоговораПлатаЗаНегативноеВоздействие().Ссылка);

    РезультатФункции = ПолучитьВсеДоговорыПоДополнительномуВиду(СписокВидовДоговоров);

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  СписокВидовДоговоров - Массив, СписокЗначений из СправочникСсылка.lc_ВидыДоговоров
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Ссылка - СправочникСсылка.ДоговорыКонтрагентов
//      * Наименование - Строка
//      * Номер - Строка
//      * Контрагент - СправочникСсылка.Контрагенты
Функция ПолучитьВсеДоговорыПоДополнительномуВиду(Знач СписокВидовДоговоров) Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ДоговорыКонтрагентов.Ссылка КАК Ссылка,
        |	ДоговорыКонтрагентов.Наименование КАК Наименование,
        |	ДоговорыКонтрагентов.Номер КАК Номер,
        |	ДоговорыКонтрагентов.Владелец КАК Контрагент
        |ИЗ
        |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
        |ГДЕ
        |	ДоговорыКонтрагентов.ЭтоГруппа = ЛОЖЬ
        |	И ДоговорыКонтрагентов.lc_ВидДоговора В (&ВидыДоговора)
        |	И ДоговорыКонтрагентов.Владелец ССЫЛКА Справочник.Контрагенты
        |";

    Запрос.УстановитьПараметр("ВидыДоговора", СписокВидовДоговоров);

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров ++
//
// Параметры:
//  ДоговорСсылка - СправочникСсылка.ДоговорыКонтрагентов - Документ для которого ищется номер
//      собственный номер этого документа будет игнорироваться
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * Значение - Число
//      * НомерСтрокой - Строка, Неопределено
//      * Договор - СправочникСсылка.ДоговорыКонтрагентов, Неопределено
Функция ПолучитьМаксимальныйНомерДоговораАбонентскогоОтдела(Знач ДоговорСсылка = Неопределено) Экспорт
    РезультатФункции = Новый Структура("Успех, Значение, НомерСтрокой, Договор", Ложь, 0);

    ДанныеДоговоров = ПолучитьВсеДоговорыАбонентскогоОтдела();

    Для Каждого СтрокаДанных Из ДанныеДоговоров Цикл
        Если ДоговорСсылка <> Неопределено И СтрокаДанных.Ссылка = ДоговорСсылка Тогда
            Продолжить; // Игнорируем текущий объект
        КонецЕсли;

        Если ПустаяСтрока(СтрокаДанных.Номер) Тогда
            Продолжить; // Не заполнен номер
        КонецЕсли;

        РезультатПреобразования = ПреобразоватьНомерДоговораВЧисло(СтрокаДанных.Номер);
        Если РезультатПреобразования.Успех = Ложь Тогда
            Продолжить; // Ошибка расшифровки
        КонецЕсли;

        ТекущийМаксимальныйНомер = Макс(РезультатПреобразования.Значение, РезультатФункции.Значение);
        Если ТекущийМаксимальныйНомер > РезультатФункции.Значение Тогда
            РезультатФункции.Значение = ТекущийМаксимальныйНомер;
            РезультатФункции.НомерСтрокой = СтрокаДанных.Номер;
            РезультатФункции.Договор = СтрокаДанных.Ссылка;
            РезультатФункции.Успех = Истина;
        КонецЕсли;
    КонецЦикла;

    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров --

// Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров ++
//
// Параметры:
//  ЗаменятьЗаполненные - Булево - По умолчанию Истина
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * ТекстСообщения - Строка, Неопределено
//      * ИзмененныеДоговоры - Массив из СправочникСсылка.ДоговорыКонтрагентов
Функция ЗаполнитьНомераДоговоровАбонентскогоОтделаПоНаименованию(Знач ЗаменятьЗаполненные = Истина) Экспорт
    СписокВидовДоговоров = Новый Массив;
    СписокВидовДоговоров.Добавить(ПолучитьДополнительныйВидДоговораАбонентскийОтдел().Ссылка);
    ТаблицаНомеровДоговоровАбонентскогоОтдела = ПолучитьТаблицуСоответствийНомеровНаименованийДоговоров(СписокВидовДоговоров);

    РезультатФункции = ЗаполнитьНомераДоговоровПоНаименованию(ТаблицаНомеровДоговоровАбонентскогоОтдела, ЗаменятьЗаполненные);
    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров --

// Параметры:
//  ЗаменятьЗаполненные - Булево - По умолчанию Истина
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * ТекстСообщения - Строка, Неопределено
//      * ИзмененныеДоговоры - Массив из СправочникСсылка.ДоговорыКонтрагентов
Функция ЗаполнитьНомераДоговоровНегативногоВоздействияПоНаименованию(Знач ЗаменятьЗаполненные = Истина) Экспорт
    СписокВидовДоговоров = Новый Массив;
    СписокВидовДоговоров.Добавить(ПолучитьДополнительныйВидДоговораПлатаЗаНегативноеВоздействие().Ссылка);
    ТаблицаНомеровДоговоров = ПолучитьТаблицуСоответствийНомеровНаименованийДоговоров(СписокВидовДоговоров);

    РезультатФункции = ЗаполнитьНомераДоговоровПоНаименованию(ТаблицаНомеровДоговоров, ЗаменятьЗаполненные);
    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  ТаблицаНомеровДоговоров - ТаблицаЗначений
//      * Ссылка - СправочникСсылка.ДоговорыКонтрагентов
//      * НомерИзНаименования - Строка
//  ЗаменятьЗаполненные - Булево - По умолчанию Истина
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * ТекстСообщения - Строка, Неопределено
//      * ИзмененныеДоговоры - Массив из СправочникСсылка.ДоговорыКонтрагентов
Функция ЗаполнитьНомераДоговоровПоНаименованию(Знач ТаблицаНомеровДоговоров, Знач ЗаменятьЗаполненные = Истина) Экспорт
    РезультатФункции = Новый Структура("Успех, ИзмененныеДоговоры, ТекстСообщения", Истина, Новый Массив);

    ЗаменятьЗаполненные = ?(ЗаменятьЗаполненные = Неопределено, Истина, ЗаменятьЗаполненные);

    НачатьТранзакцию();
    Попытка
        Для Каждого СтрокаДанных Из ТаблицаНомеровДоговоров Цикл
            СущНомерДоговора = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаДанных.Ссылка, "Номер");
            Если ЗаменятьЗаполненные = Ложь И ПустаяСтрока(СокрЛП(СущНомерДоговора)) = Ложь Тогда
                Продолжить; // Номер уже заполнен
            КонецЕсли;

            Если СущНомерДоговора = СтрокаДанных.НомерИзНаименования Тогда
                Продолжить; // Нет изменений
            КонецЕсли;

            ДоговорОбъект = СтрокаДанных.Ссылка.ПолучитьОбъект();
            ДоговорОбъект.Номер = СтрокаДанных.НомерИзНаименования;

            ДоговорОбъект.Записать();
            РезультатФункции.ИзмененныеДоговоры.Добавить(ДоговорОбъект.Ссылка);
        КонецЦикла;

        ЗафиксироватьТранзакцию();

    Исключение
        ОтменитьТранзакцию();

        РезультатФункции.Успех = Ложь;
        РезультатФункции.ИзмененныеДоговоры.Очистить();
        РезультатФункции.ТекстСообщения = СтрШаблон(
                "Ошибка при записи / формировании номеров договоров.
                |Информация: %1", ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров ++
//
// Получает номер договора из наименования договора
// Параметры:
//  НаименованиеДоговора - Строка
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * Номер - Строка
//      * Суффикс - Строка - Суффикс номера
Функция ПолучитьНомерДоговораПоНаименованию(Знач НаименованиеДоговора) Экспорт
    РезультатФункции = Новый Структура("Успех, Номер, Суффикс", Ложь);

    ШаблонПоиска =
        "(?i)^\s*Договор\s*[#№N]\s*([0-9]+)\s*((?:[\\/_-]+\s*[0-9а-яА-ЯЁёa-zA-Z]+)?)";
    РезультатПоиска = СтрНайтиПоРегулярномуВыражению(НаименованиеДоговора, ШаблонПоиска);

    // Проверка найденных групп
    НайденныеГруппы = РезультатПоиска.ПолучитьГруппы();
    Если РезультатПоиска.НачальнаяПозиция = 0 ИЛИ НайденныеГруппы.Количество() < 1 Тогда
        Возврат РезультатФункции; // Номер не найден
    КонецЕсли;

    // Формирование результата
    РезультатФункции.Успех = Истина;
    РезультатФункции.Номер = НайденныеГруппы[0].Значение;
    РезультатФункции.Суффикс = ?(НайденныеГруппы.Количество() > 1 И ПустаяСтрока(СокрЛП(НайденныеГруппы[1].Значение)) = Ложь,
            СтрЗаменитьПоРегулярномуВыражению(НайденныеГруппы[1].Значение, "^[\\/_-]+\s*", ""), "");

    Возврат РезультатФункции;
КонецФункции // // Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров --

// Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров ++
//
// Параметры:
//  НомерДоговора - Строка
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * Значение - Неопределено
Функция ПреобразоватьНомерДоговораВЧисло(Знач НомерДоговора) Экспорт
    РезультатФункции = Новый Структура("Успех, Значение", Ложь);

    ШаблонПоиска =
        "^\s*([0-9]+)[^0-9]*";
    РезультатПоиска = СтрНайтиПоРегулярномуВыражению(НомерДоговора, ШаблонПоиска);

    // Проверка найденных групп
    НайденныеГруппы = РезультатПоиска.ПолучитьГруппы();
    Если РезультатПоиска.НачальнаяПозиция = 0 ИЛИ НайденныеГруппы.Количество() < 1 Тогда
        Возврат РезультатФункции; // Номер не найден
    КонецЕсли;

    // Формирование результата
    РезультатФункции.Успех = Истина;
    РезультатФункции.Значение = СтроковыеФункцииКлиентСервер.СтрокаВЧисло(НайденныеГруппы[0].Значение);

    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 19.11.2024 [F00231185] авто-нумерация договоров --

// Параметры:
//  НомерДоговора - Строка
// Возвращаемое значение:
//  - Число
Функция ПреобразоватьНомерДоговораВЧислоПринудительно(Знач НомерДоговора) Экспорт
    РезультатФункции = 0;

    РезультатПреобразования = ПреобразоватьНомерДоговораВЧисло(НомерДоговора);
    Если РезультатПреобразования.Успех = Ложь Тогда
        Возврат РезультатФункции;
    КонецЕсли;

    // Формирование результата
    РезультатФункции = РезультатПреобразования.Значение;
    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  Договор - СправочникСсылка.ДоговорыКонтрагентов, СправочникОбъект.ДоговорыКонтрагентов
// Возвращаемое значение:
//  - Булево
Функция ЭтоДоговорАбонентскогоОтдела(Знач Договор) Экспорт
    ДополнительныйВидДоговора = Неопределено;
    Если ТипЗнч(Договор) = Тип("СправочникСсылка.ДоговорКонтрагента") Тогда
        ДополнительныйВидДоговора = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "lc_ВидДоговора");
        Возврат ДополнительныйВидДоговора = ПолучитьДополнительныйВидДоговораАбонентскийОтдел().Ссылка;
    Иначе
        ДополнительныйВидДоговора = Договор.lc_ВидДоговора;
    КонецЕсли;

    Возврат ДополнительныйВидДоговора = ПолучитьДополнительныйВидДоговораАбонентскийОтдел().Ссылка;
КонецФункции

// Получает таблицу соответствия договоров негативного воздействия договорам абонентского отдела.
//  прим. Договор № 1000 (Негативное воздействие) == Договор № 1000
//  Соответствие определяется по номерам договоров принадлежащих одному контрагенту
// Параметры:
//  МассивДоговоровНегативногоВоздействия - Массив из СправочникСсылка.ДоговорыКонтрагентов - Договоры отбора
//  МассивДоговоровАбонентскогоОтдела - Массив из СправочникСсылка.ДоговорыКонтрагентов - Договоры отбора
//  МягкоеУсловиеСравнения - Булево - По умолчанию Ложь. Если Истина альтернативно равенству номеров проверяется условие подобия наименований
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Договор - СправочникСсылка.ДоговорыКонтрагентов
//      * ДоговорНегативноеВоздействие - СправочникСсылка.ДоговорыКонтрагентов
//      * Наименование - Строка
//      * НаименованиеНегативноеВоздействие - Строка
//      * Номер - Строка
//      * Контрагент - СправочникСсылка.Контрагенты
Функция ПолучитьСоответствияДоговоровНегативногоВоздействия(
        Знач МассивДоговоровНегативногоВоздействия = Неопределено,
        Знач МассивДоговоровАбонентскогоОтдела = Неопределено, Знач МягкоеУсловиеСравнения = Ложь) Экспорт

    ДоговорыАбонентскогоОтдела = ПолучитьВсеДоговорыАбонентскогоОтдела();
    ДоговорыНегативногоВоздействия = ПолучитьВсеДоговорыНегативногоВоздействия();

    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ДоговорыАбонентскогоОтдела.Ссылка КАК Ссылка,
        |	ДоговорыАбонентскогоОтдела.Наименование КАК Наименование,
        |	ДоговорыАбонентскогоОтдела.Номер КАК Номер,
        |	ДоговорыАбонентскогоОтдела.Контрагент КАК Контрагент
        |ПОМЕСТИТЬ ВТ_ДоговорыАбонентскогоОтдела
        |ИЗ
        |	&ДоговорыАбонентскогоОтдела КАК ДоговорыАбонентскогоОтдела
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ДоговорыНегативногоВоздействия.Ссылка КАК Ссылка,
        |	ДоговорыНегативногоВоздействия.Наименование КАК Наименование,
        |	ДоговорыНегативногоВоздействия.Номер КАК Номер,
        |	ДоговорыНегативногоВоздействия.Контрагент КАК Контрагент
        |ПОМЕСТИТЬ ВТ_ДоговорыНегативногоВоздействия
        |ИЗ
        |	&ДоговорыНегативногоВоздействия КАК ДоговорыНегативногоВоздействия
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |	ВТ_ДоговорыАбонентскогоОтдела.Ссылка КАК Договор,
        |	ВТ_ДоговорыАбонентскогоОтдела.Наименование КАК Наименование,
        |	ВТ_ДоговорыАбонентскогоОтдела.Номер КАК Номер,
        |	ВТ_ДоговорыАбонентскогоОтдела.Контрагент КАК Контрагент,
        |	ВТ_ДоговорыНегативногоВоздействия.Ссылка КАК ДоговорНегативноеВоздействие,
        |	ВТ_ДоговорыНегативногоВоздействия.Наименование КАК НаименованиеНегативноеВоздействие
        |ИЗ
        |	ВТ_ДоговорыАбонентскогоОтдела КАК ВТ_ДоговорыАбонентскогоОтдела
        |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ДоговорыНегативногоВоздействия КАК ВТ_ДоговорыНегативногоВоздействия
        |		ПО ВТ_ДоговорыАбонентскогоОтдела.Ссылка <> ВТ_ДоговорыНегативногоВоздействия.Ссылка
        |           И &ДополнительныеУсловияОтбора
        |			И ((ВТ_ДоговорыАбонентскогоОтдела.Номер = ВТ_ДоговорыНегативногоВоздействия.Номер
        |			    И (ВТ_ДоговорыАбонентскогоОтдела.Номер <> """")) ИЛИ (&АльтернативноеУсловиеСравнения))
        |			И ВТ_ДоговорыАбонентскогоОтдела.Контрагент = ВТ_ДоговорыНегативногоВоздействия.Контрагент
        |   			//И ВТ_ДоговорыНегативногоВоздействия.Наименование ПОДОБНО ВТ_ДоговорыАбонентскогоОтдела.Наименование + ""%""
        |";

    ДополнительныеУсловияОтбора = "ИСТИНА";

    Если МассивДоговоровАбонентскогоОтдела <> Неопределено Тогда
        ДополнительныеУсловияОтбора = СтрШаблон("%1 И %2", ДополнительныеУсловияОтбора,
                "ВТ_ДоговорыАбонентскогоОтдела.Ссылка В (&МассивДоговоровАбонентскогоОтдела)");

        Запрос.УстановитьПараметр("МассивДоговоровАбонентскогоОтдела", МассивДоговоровАбонентскогоОтдела);
    КонецЕсли;

    Если МассивДоговоровНегативногоВоздействия <> Неопределено Тогда
        ДополнительныеУсловияОтбора = СтрШаблон("%1 И %2", ДополнительныеУсловияОтбора,
                "ВТ_ДоговорыНегативногоВоздействия.Ссылка В (&МассивДоговоровНегативногоВоздействия)");

        Запрос.УстановитьПараметр("МассивДоговоровНегативногоВоздействия", МассивДоговоровНегативногоВоздействия);
    КонецЕсли;

    Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ДополнительныеУсловияОтбора", ДополнительныеУсловияОтбора);

    Если МягкоеУсловиеСравнения = Истина Тогда
        АльтернативноеУсловиеСравнения =
            "ВТ_ДоговорыНегативногоВоздействия.Наименование ПОДОБНО ВТ_ДоговорыАбонентскогоОтдела.Наименование + ""%негатив%""";
        Запрос.Текст = СтрЗаменить(Запрос.Текст, "&АльтернативноеУсловиеСравнения", АльтернативноеУсловиеСравнения);
    Иначе
        Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИЛИ (&АльтернативноеУсловиеСравнения)", "");
    КонецЕсли;

    Запрос.УстановитьПараметр("ДоговорыАбонентскогоОтдела", ДоговорыАбонентскогоОтдела);
    Запрос.УстановитьПараметр("ДоговорыНегативногоВоздействия", ДоговорыНегативногоВоздействия);

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции

// Получает таблицу договоров (для взаиморасчетов по л/с) по списку Помещений
// Параметры:
//  СписокПомещений - Массив, СписокЗначений из СправочникСсылка.УПЖКХ_Помещения
//  ДатаАктуальности - Дата, Неопределено
//  Организация - СправочникСсылка.Организации, Неопределено
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * ЛицевойСчет - СправочникСсылка.КВП_ЛицевыеСчета
//      * Здание - СправочникСсылка.КВП_Здания
//      * Помещение - СправочникСсылка.УПЖКХ_Помещения
//      * Договор - СправочникСсылка.ДоговорыКонтрагентов
Функция ПолучитьТаблицуДоговоровВзаиморасчетовПоЛСПомещений(
        Знач СписокПомещений, Знач ДатаАктуальности = Неопределено, Знач Организация = Неопределено) Экспорт

    Организация = ?(Организация = Неопределено, УПЖКХ_ТиповыеМетодыВызовСервера.ПолучитьОсновнуюОрганизацию(), Организация);

    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
        |   Помещения.Ссылка КАК Помещение,
        |   ВЫРАЗИТЬ(Помещения.Владелец КАК Справочник.КВП_Здания) КАК Здание
        |ПОМЕСТИТЬ ВТ_ЗданияПомещения
        |ИЗ
        |   Справочник.УПЖКХ_Помещения КАК Помещения
        |ГДЕ
        |   Помещения.Ссылка В (&СписокПомещений)
        |;
        |
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |   ЛицевыеСчета.Ссылка КАК ЛицевойСчет,
        |   ВТ_ЗданияПомещения.Здание КАК Здание,
        |   ВТ_ЗданияПомещения.Помещение КАК Помещение
        |ПОМЕСТИТЬ ВТ_ЛицевыеСчетаПомещений
        |ИЗ
        |   Справочник.КВП_ЛицевыеСчета КАК ЛицевыеСчета
        |   ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ЗданияПомещения КАК ВТ_ЗданияПомещения
        |   ПО ЛицевыеСчета.ЭтоГруппа = Ложь
        |   И ЛицевыеСчета.ПометкаУдаления = ЛОЖЬ
        |   И ЛицевыеСчета.Адрес = ВТ_ЗданияПомещения.Помещение
        |;
        |
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |   СведенияДляВзаиморасчетовПоЛС.ЛицевойСчет КАК ЛицевойСчет,
        |   СведенияДляВзаиморасчетовПоЛС.Договор КАК Договор
        |ПОМЕСТИТЬ ВТ_ДоговорыЛС
        |ИЗ
        |   РегистрСведений.УПЖКХ_СведенияДляВзаиморасчетовПоЛС.СрезПоследних(&ДатаАктуальности) КАК СведенияДляВзаиморасчетовПоЛС
        |ГДЕ
        |   СведенияДляВзаиморасчетовПоЛС.Организация = &Организация
        |   И СведенияДляВзаиморасчетовПоЛС.ЛицевойСчет В (ВЫБРАТЬ Т.ЛицевойСчет ИЗ ВТ_ЛицевыеСчетаПомещений КАК Т)
        |;
        |
        |ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |   ВТ_ЛицевыеСчетаПомещений.ЛицевойСчет КАК ЛицевойСчет,
        |   ВТ_ЛицевыеСчетаПомещений.Здание КАК Здание,
        |   ВТ_ЛицевыеСчетаПомещений.Помещение КАК Помещение,
        |   ВТ_ДоговорыЛС.Договор КАК Договор
        |ИЗ
        |   ВТ_ЛицевыеСчетаПомещений КАК ВТ_ЛицевыеСчетаПомещений
        |   ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ДоговорыЛС КАК ВТ_ДоговорыЛС
        |   ПО ВТ_ЛицевыеСчетаПомещений.ЛицевойСчет = ВТ_ДоговорыЛС.ЛицевойСчет
        |";

    Запрос.УстановитьПараметр("СписокПомещений", СписокПомещений);
    Запрос.УстановитьПараметр("Организация", Организация);
    Если ДатаАктуальности = Неопределено Тогда
        Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ДатаАктуальности", "");
    Иначе
        Запрос.УстановитьПараметр("ДатаАктуальности", ДатаАктуальности);
    КонецЕсли;

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции

// Гарант+ Килипенко 24.12.2024 [F00232648] Очистка наименования договора от даты ++
//
// Параметры:
//  НаименованиеДоговора - Строка
// Возвращаемое значение:
//  - Строка - Наименование договора без даты, прим: Договор № 100 от 20.01.2021г -> Договор № 100
Функция ОчиститьНаименованиеДоговораОтПрефикснойДаты(Знач НаименованиеДоговора) Экспорт
    ШаблонЗамены = "(?i)(?:\s*(?:от)|(?:на)\s*)?\s*[0-9]{1,2}[\.\-,\s][0-9]{2}[\.\-,\s][0-9]{2,4}(?:\s*г\s*\.?)?\s*$";
    РезультатФункции = СтрЗаменитьПоРегулярномуВыражению(НаименованиеДоговора, ШаблонЗамены, "");
    Возврат РезультатФункции;
КонецФункции // Гарант+ Килипенко 24.12.2024 [F00232648] Очистка наименования договора от даты --

// Параметры:
//  МассивДоговоров - Массив из СправочникСсылка.ДоговорыКонтрагентов - Договоры отбора
//  МягкоеУсловиеСравнения - Булево - По умолчанию Ложь. Если Истина альтернативно равенству номеров проверяется условие подобия наименований
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * Договор - СправочникСсылка.ДоговорыКонтрагентов
//      * ДоговорНегативноеВоздействие - СправочникСсылка.ДоговорыКонтрагентов
//      * Наименование - Строка
//      * НаименованиеНегативноеВоздействие - Строка
//      * Номер - Строка
//      * Контрагент - СправочникСсылка.Контрагенты
Функция ПолучитьАбонентскиеДоговорыПоДоговорамНегативногоВоздействия(Знач МассивДоговоров, Знач МягкоеУсловиеСравнения = Ложь) Экспорт
    ТаблицаСоответствийДоговоров = ПолучитьСоответствияДоговоровНегативногоВоздействия(
        МассивДоговоров, Неопределено, МягкоеУсловиеСравнения);
    Возврат ТаблицаСоответствийДоговоров;
КонецФункции

#Область Константы

// Возвращаемое значение:
//  - Структура
//      * Ссылка - СправочникСсылка.lc_ВидыДоговоров
//      * Код - Строка
//      * Наименование - Строка
Функция ПолучитьДополнительныйВидДоговораАбонентскийОтдел() Экспорт
    РезультатФункции = Новый Структура("Ссылка, Код, Наименование");
    РезультатФункции.Код = "000000004";

    РезультатФункции.Ссылка = Справочники.lc_ВидыДоговоров.НайтиПоКоду(РезультатФункции.Код, Истина);
    Если ЗначениеЗаполнено(РезультатФункции) = Ложь Тогда
        ВызватьИсключение("Отсутствует обязательный элемент ""Абонентский отдел"" справочника ""lc_ВидыДоговоров""");
    КонецЕсли;

    РезультатФункции.Наименование = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(РезультатФункции.Ссылка, "Наименование");

    Возврат РезультатФункции;
КонецФункции

// Возвращаемое значение:
//  - Структура
//      * Ссылка - СправочникСсылка.lc_ВидыДоговоров
//      * Код - Строка
//      * Наименование - Строка
Функция ПолучитьДополнительныйВидДоговораПлатаЗаНегативноеВоздействие() Экспорт
    РезультатФункции = Новый Структура("Ссылка, Код, Наименование");
    РезультатФункции.Код = "000000005";

    РезультатФункции.Ссылка = Справочники.lc_ВидыДоговоров.НайтиПоКоду(РезультатФункции.Код, Истина);
    Если ЗначениеЗаполнено(РезультатФункции) = Ложь Тогда
        ВызватьИсключение("Отсутствует обязательный элемент ""Плата за негативное воздействие"" справочника ""lc_ВидыДоговоров""");
    КонецЕсли;

    РезультатФункции.Наименование = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(РезультатФункции.Ссылка, "Наименование");

    Возврат РезультатФункции;
КонецФункции

#КонецОбласти // Константы

#КонецОбласти // ПрограммныйИнтерфейс
