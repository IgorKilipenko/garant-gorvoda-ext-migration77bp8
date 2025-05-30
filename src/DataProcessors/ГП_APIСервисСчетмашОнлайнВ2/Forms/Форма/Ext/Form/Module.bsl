﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
    // Режим доступа
    УстановитьРежимРаботыНаСервере(НЕ Константы.ГП_ВключенОсновнойРежимРаботыВебКассыСчетмаш.Получить());

    ЭтотОбъект.Объект.Организация = ?(ЗначениеЗаполнено(ЭтотОбъект.Объект.Организация) = Ложь,
            УПЖКХ_ТиповыеМетодыВызовСервера.ПолучитьОсновнуюОрганизацию(), ЭтотОбъект.Объект.Организация);

    // Временно установлено принудительное обновление токена, т.к. в тесте токен заканчивается раньше
    РезультатПроверкиСоединения = ГП_СчетмашAPI.ПроверитьСоединениеСчетмаш(ЭтотОбъект.Объект.Логин, Истина);

    Если РезультатПроверкиСоединения.Успех Тогда
        ОбщегоНазначения.СообщитьПользователю("Соединение с сервером установлено");
    Иначе
        ОбщегоНазначения.СообщитьПользователю(РезультатПроверкиСоединения.ТекстСообщения);
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыборПериода(Команда)
    ВыбранныйПериод = Новый СтандартныйПериод;
    ВыбранныйПериод.ДатаНачала = ЭтотОбъект.Объект.ДатаНачала;
    ВыбранныйПериод.ДатаОкончания = ЭтотОбъект.Объект.ДатаОкончания;

    Диалог = Новый ДиалогРедактированияСтандартногоПериода();
    Диалог.Период = ВыбранныйПериод;

    Диалог.Показать(Новый ОписаниеОповещения("ВыборПериодаЗавершение", ЭтотОбъект, Новый Структура("Диалог", Диалог)));
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьЗаполнениеДанныеОплат(Команда)
    ЗаполненоУспешно = ЗаполнитьДанныеОплатНаСервере();

    Если НЕ ЗаполненоУспешно Тогда
        ЭтотОбъект.Объект.РасшифровкаРегистрацийОплат.Очистить();
        ЭтотОбъект.Объект.СтрокиРегистрацииОплат.Очистить();
        ПоказатьПредупреждение( , "Прервано! Исправьте ошибки.", , "Ошибка при заполнении");

        Возврат;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьПробитиеЧека(Команда)
    ЭтоВариантВыполненияКомандыПоВсемСтрокам = СтрНайти(Команда.Имя, "ДляВсехСтрок", НаправлениеПоиска.СКонца) > 0;

    Если ЭтоВариантВыполненияКомандыПоВсемСтрокам = Ложь Тогда
        // Только по текущей строке
        ТекущаяСтрокаОплаты = ЭтотОбъект.Элементы.СтрокиРегистрацииОплат.ТекущиеДанные;
        Если ТекущаяСтрокаОплаты = Неопределено Тогда
            ОбщегоНазначенияКлиент.СообщитьПользователю("Не выбрана строка оплаты");
            Возврат;
        КонецЕсли;

        РезультатДиалога = Ждать ВопросАсинх(СтрШаблон(
                    "Будет выполнена регистрация чека ""Приход"" для контрагента: %1
                    |Продолжить?", ТекущаяСтрокаОплаты.Контрагент), РежимДиалогаВопрос.ДаНет, 0, , "Регистрация чека (приход)");

        Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
            Возврат; // Отказ пользователя
        КонецЕсли;

        ТипОперацииРегистрации = ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().Приход;
        РезультатПробитияЧека = ПробитьЧекСчетмаш(
                ТипОперацииРегистрации,
                ТекущаяСтрокаОплаты);
    Иначе
        // По всем строкам
        РезультатДиалога = Ждать ВопросАсинх(СтрШаблон(
                    "Будет выполнена регистрация чеков ""Приход"" для всех строк.
                    |Продолжить?"), РежимДиалогаВопрос.ДаНет, 0, , "Регистрация чека (приход)");

        Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
            Возврат; // Отказ пользователя
        КонецЕсли;

        ТипОперацииРегистрации = ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().Приход;
        Для Каждого ТекущаяСтрокаОплаты Из ЭтотОбъект.Объект.СтрокиРегистрацииОплат Цикл
            РезультатПробитияЧека = ПробитьЧекСчетмаш(
                    ТипОперацииРегистрации,
                    ТекущаяСтрокаОплаты);
        КонецЦикла;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьВозвратПриходаЧека(Команда)
    ТекущаяСтрокаОплаты = ЭтотОбъект.Элементы.СтрокиРегистрацииОплат.ТекущиеДанные;
    Если ТекущаяСтрокаОплаты = Неопределено Тогда
        ОбщегоНазначенияКлиент.СообщитьПользователю("Не выбрана строка оплаты");
        Возврат;
    КонецЕсли;

    РезультатДиалога = Ждать ВопросАсинх(СтрШаблон(
                "Будет выполнен возврат регистрации чека ""Приход"" для контрагента: %1
                |Продолжить?", ТекущаяСтрокаОплаты.Контрагент), РежимДиалогаВопрос.ДаНет, 0, , "Возврат чека (приход)");

    Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
        Возврат; // Отказ пользователя
    КонецЕсли;

    РезультатПробитияЧека = ВозвратПриходаЧекаСчетмаш(ТекущаяСтрокаОплаты);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПроверкуСтатусаЧека(Команда)
    ЭтоВариантВыполненияКомандыПоВсемСтрокам = СтрНайти(Команда.Имя, "ДляВсехСтрок", НаправлениеПоиска.СКонца) > 0;

    Если ЭтоВариантВыполненияКомандыПоВсемСтрокам = Ложь Тогда
        // Только по текущей строке
        ТекущаяСтрокаОплаты = ЭтотОбъект.Элементы.СтрокиРегистрацииОплат.ТекущиеДанные;
        Если ТекущаяСтрокаОплаты = Неопределено Тогда
            ОбщегоНазначенияКлиент.СообщитьПользователю("Не выбрана строка оплаты");
            Возврат;
        КонецЕсли;

        ПроверитьСтатусаЧека(ТекущаяСтрокаОплаты);
        Состояние("Обновление статуса чека завешено");

    Иначе
        Для Каждого ТекущаяСтрокаОплаты Из ЭтотОбъект.Объект.СтрокиРегистрацииОплат Цикл
            РезультатПроверки = ПроверитьСтатусаЧека(ТекущаяСтрокаОплаты, Истина);
        КонецЦикла;

        Состояние("Обновление статусов чеков завешено");
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьКоррекциюПрихода(Команда)
    ЭтоВариантВыполненияКомандыПоВсемСтрокам = СтрНайти(Команда.Имя, "ДляВсехСтрок", НаправлениеПоиска.СКонца) > 0;

    Если ЭтоВариантВыполненияКомандыПоВсемСтрокам = Ложь Тогда
        // Только по текущей строке
        ТекущаяСтрокаОплаты = ЭтотОбъект.Элементы.СтрокиРегистрацииОплат.ТекущиеДанные;
        Если ТекущаяСтрокаОплаты = Неопределено Тогда
            ОбщегоНазначенияКлиент.СообщитьПользователю("Не выбрана строка оплаты");
            Возврат;
        КонецЕсли;

        РезультатДиалога = Ждать ВопросАсинх(СтрШаблон(
                    "Будет выполнена регистрация коррекции чека ""Приход"" для контрагента: %1
                    |Продолжить?", ТекущаяСтрокаОплаты.Контрагент), РежимДиалогаВопрос.ДаНет, 0, , "Регистрация коррекции чека (приход)");

        Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
            Возврат; // Отказ пользователя
        КонецЕсли;

        ТипОперацииРегистрации = ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().КоррекцияПрихода;
        РезультатПробитияЧека = ПробитьЧекСчетмаш(
                ТипОперацииРегистрации,
                ТекущаяСтрокаОплаты);

    Иначе
        // По всем строкам
        РезультатДиалога = Ждать ВопросАсинх(СтрШаблон(
                    "Будет выполнена регистрация коррекции чеков для всех строк.
                    |Продолжить?"), РежимДиалогаВопрос.ДаНет, 0, , "Регистрация коррекции чека (приход)");

        Если РезультатДиалога <> КодВозвратаДиалога.Да Тогда
            Возврат; // Отказ пользователя
        КонецЕсли;

        ТипОперацииРегистрации = ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().КоррекцияПрихода;
        Для Каждого ТекущаяСтрокаОплаты Из ЭтотОбъект.Объект.СтрокиРегистрацииОплат Цикл
            РезультатПробитияЧека = ПробитьЧекСчетмаш(
                    ТипОперацииРегистрации,
                    ТекущаяСтрокаОплаты);
        КонецЦикла;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиКомандФормы

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура СтрокиРегистрацииОплатПриАктивизацииСтроки(Элемент)
    СтандартнаяОбработка = Ложь;

    Если Элементы.СтрокиРегистрацииОплат.ТекущиеДанные <> Неопределено Тогда
        ЭтотОбъект.РасшифровкаСтрокиРегистрацииОплат.Очистить();

        СтруктураПараметровОтбора = Новый Структура;
        СтруктураПараметровОтбора.Вставить("external_id", Элементы.СтрокиРегистрацииОплат.ТекущиеДанные.external_id);

        НайденныеСтроки = ЭтотОбъект.Объект.РасшифровкаРегистрацийОплат.НайтиСтроки(СтруктураПараметровОтбора);

        ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат = Новый Структура("Сумма, Аванс, Пени", 0, 0, 0);
        Для Каждого ТекущаяСтрокаРасшифровки Из НайденныеСтроки Цикл
            НоваяСтрокаДляОтображения = ЭтотОбъект.РасшифровкаСтрокиРегистрацииОплат.Добавить();
            ЗаполнитьЗначенияСвойств(НоваяСтрокаДляОтображения, ТекущаяСтрокаРасшифровки);

            // Накопление итогов
            ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Сумма =
                ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Сумма + НоваяСтрокаДляОтображения.Сумма;
            ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Аванс =
                ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Аванс + НоваяСтрокаДляОтображения.Аванс;
            ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Пени =
                ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Пени + НоваяСтрокаДляОтображения.Пени;
        КонецЦикла;

        ФорматСуммыИтоговПодвала = "ЧДЦ=2";
        // Заполнение итогов подвала
        ЭтотОбъект.Элементы.РасшифровкаСтрокиРегистрацииОплатСумма.ТекстПодвала =
            Формат(ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Сумма, ФорматСуммыИтоговПодвала);
        ЭтотОбъект.Элементы.РасшифровкаСтрокиРегистрацииОплатАванс.ТекстПодвала =
            Формат(ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Аванс, ФорматСуммыИтоговПодвала);
        ЭтотОбъект.Элементы.РасшифровкаСтрокиРегистрацииОплатПени.ТекстПодвала =
            Формат(ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Пени, ФорматСуммыИтоговПодвала);

        // Контроль сумм
        ДопустимаяПогрешностьСравненияСумм = 0.0001;
        РасхождениеСуммСтрокиОплаты = ИтогиТаблицыРасшифровкаСтрокиРегистрацииОплат.Сумма
            - ЭтотОбъект.Элементы.СтрокиРегистрацииОплат.ТекущиеДанные.Сумма;
        Если ГП_ВспомогательныеФункцииКлиентСервер.АбсолютноеЗначение(
                РасхождениеСуммСтрокиОплаты) > ДопустимаяПогрешностьСравненияСумм Тогда

            ОбщегоНазначенияКлиент.СообщитьПользователю(СтрШаблон(
                    "ВНИМАНИЕ! В строке оплаты № %1 общая сумма не совпадает с суммой расшифровкой",
                    Элементы.СтрокиРегистрацииОплат.ТекущиеДанные.НомерСтроки));
        КонецЕсли;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СтрокиФиксированныхТаблицПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
    Отказ = Истина;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовФормы

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыборПериодаЗавершение(Период, ДополнительныеПараметры) Экспорт
    Диалог = ДополнительныеПараметры.Диалог;

    Если ЗначениеЗаполнено(Период) Тогда
        ВыбранныйПериод = Диалог.Период;
        ЭтотОбъект.Объект.ДатаНачала = ВыбранныйПериод.ДатаНачала;
        ЭтотОбъект.Объект.ДатаОкончания = ВыбранныйПериод.ДатаОкончания;
    КонецЕсли;
КонецПроцедуры

#Область ЗаполнениеДанных

// Устарела. Не используется
// Гарант+ Килипенко 11.02.2025 Признак выгрузки в ОФД ++
// ~ Переработана полностью ~
//
&НаСервере
Процедура Удалить_ПолучитьОбщуюТаблицуРасшифровкиОплат()
    // Гарант+ Килипенко 11.02.2025 Признак выгрузки в ОФД ++
    ТаблицаРасшифровкиОплатДляОФД = ГП_ОбменОФД.ПолучитьСвернутуюОбщуюТаблицуРасшифровкиОплатДляОФД(
            НачалоДня(ЭтотОбъект.Объект.ДатаНачала),
            КонецДня(ЭтотОбъект.Объект.ДатаОкончания),
            ?(ЭтотОбъект.ЛицевойСчет.Пустая(), Неопределено, ЭтотОбъект.ЛицевойСчет),
            ЭтотОбъект.Объект.Организация);

    ЭтотОбъект.Объект.ОбщаяТаблицаРасшифровкиОплат.Очистить();
    ЭтотОбъект.Объект.ОбщаяТаблицаРасшифровкиОплат.Загрузить(ТаблицаРасшифровкиОплатДляОФД);
КонецПроцедуры // Гарант+ Килипенко 11.02.2025 Признак выгрузки в ОФД --

&НаСервере
Функция ЗаполнитьДанныеОплатНаСервере()
    ЭтотОбъект.Объект.СтрокиРегистрацииОплат.Очистить();
    ЭтотОбъект.Объект.РасшифровкаРегистрацийОплат.Очистить();
    ЭтотОбъект.РасшифровкаСтрокиРегистрацииОплат.Очистить();

    ДанныеЗаполнения = ГП_ОбменОФД.СобратьДанныеЧековСчетмаш(
            НачалоДня(ЭтотОбъект.Объект.ДатаНачала),
            КонецДня(ЭтотОбъект.Объект.ДатаОкончания),
            Новый Структура("Контрагент, Организация",
                ?(ЭтотОбъект.Контрагент.Пустая(), Неопределено, ЭтотОбъект.Контрагент),
                ЭтотОбъект.Объект.Организация));

    Для Каждого СтрокаДанныхЗаполнения Из ДанныеЗаполнения.ТаблицаОплат Цикл
        НоваяСтрокаОплаты = ЭтотОбъект.Объект.СтрокиРегистрацииОплат.Добавить();
        ЗаполнитьЗначенияСвойств(НоваяСтрокаОплаты, СтрокаДанныхЗаполнения);
        НоваяСтрокаОплаты.timestamp = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаДанныхЗаполнения.Документ, "Дата");

        // Формирование идентификатора
        ДанныеДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтрокаДанныхЗаполнения.Документ, "Дата, Номер");
        ДанныеКонтрагента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтрокаДанныхЗаполнения.Контрагент, "Код");
        НоваяСтрокаОплаты.external_id = ГП_ОбменОФД.СформироватьВнешнийИдентификаторЧекаСчетмаш(
                ДанныеДокумента, ДанныеКонтрагента);
        Если ПустаяСтрока(НоваяСтрокаОплаты.external_id) Тогда
            НоваяСтрокаОплаты.external_id = "";
            ВызватьИсключение("Ошибка формирования идентификатора");
        КонецЕсли;
        НоваяСтрокаОплаты.type = 1; // Электронный по умолчанию

        НайденныеСтрокиРасшифровки = ДанныеЗаполнения.РасшифровкаОплатДляЧеков.НайтиСтроки(
                Новый Структура("Документ, Контрагент", СтрокаДанныхЗаполнения.Документ, СтрокаДанныхЗаполнения.Контрагент));
        Для Каждого СтрокаДанныхЗаполненияРасшифровки Из НайденныеСтрокиРасшифровки Цикл
            НоваяСтрокаРасшифровки = ЭтотОбъект.Объект.РасшифровкаРегистрацийОплат.Добавить();
            ЗаполнитьЗначенияСвойств(НоваяСтрокаРасшифровки, СтрокаДанныхЗаполненияРасшифровки);
            НоваяСтрокаРасшифровки.external_id = НоваяСтрокаОплаты.external_id;
            НоваяСтрокаРасшифровки.Аванс = ?(СтрокаДанныхЗаполненияРасшифровки.ЭтоАванс = Истина, НоваяСтрокаРасшифровки.Сумма, 0);
            НоваяСтрокаРасшифровки.Пени = ?(СтрокаДанныхЗаполненияРасшифровки.ЭтоПени = Истина, НоваяСтрокаРасшифровки.Сумма, 0);
        КонецЦикла;
    КонецЦикла;

    Возврат Истина;
КонецФункции

// Устарела. Требует рефакторинг
&НаСервере
Функция ПолучитьТаблицуОстатковВзаиморасчетовПоДокументу(Знач Документ, Знач СписокЛицевыхСчетов, Знач Услуга = Неопределено)
    Если ТипЗнч(СписокЛицевыхСчетов) = Тип("СправочникСсылка.КВП_ЛицевыеСчета") Тогда
        СписокЛицевыхСчетов = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(СписокЛицевыхСчетов);
    КонецЕсли;

    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
        |    ВзаиморасчетыПоЛицевымСчетамОстатки.ЛицевойСчет КАК ЛицевойСчет,
        |    ВзаиморасчетыПоЛицевымСчетамОстатки.Услуга КАК Услуга,
        |    ВзаиморасчетыПоЛицевымСчетамОстатки.СуммаНачисленияОстаток КАК СуммаНачисленияОстаток
        |ИЗ
        |    РегистрНакопления.КВП_ВзаиморасчетыПоЛицевымСчетам.Остатки(
        |       &Дата,
        |       ЛицевойСчет В (&СписокЛицевыхСчетов)
        |       И &ДополнительныеУсловия) КАК ВзаиморасчетыПоЛицевымСчетамОстатки
        |";

    ДополнительныеУсловияТаблицы = "ИСТИНА";
    Если Услуга <> Неопределено Тогда
        ДополнительныеУсловияТаблицы = СтрШаблон("%1 И (Услуга = &Услуга)", ДополнительныеУсловияТаблицы);
        Запрос.УстановитьПараметр("Услуга", Услуга);
    КонецЕсли;
    Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ДополнительныеУсловияТаблицы", ДополнительныеУсловияТаблицы);

    Запрос.УстановитьПараметр("СписокЛицевыхСчетов", СписокЛицевыхСчетов);
    Запрос.УстановитьПараметр("Дата", Новый Граница(Документ.МоментВремени(), ВидГраницы.Включая));

    Возврат Запрос.Выполнить().Выгрузить();
КонецФункции

#КонецОбласти // ЗаполнениеДанных

#Область РаботаСЧеками

&НаКлиенте
Функция ПробитьЧекСчетмаш(Знач ТипОперации, ТекущаяСтрокаОплаты)
    РезультатФункции = Новый Структура("Успех, Результат", Истина);

    РезультатПроверкиСтатуса = ПроверитьСтатусаЧека(ТекущаяСтрокаОплаты);
    Если (РезультатПроверкиСтатуса.Успех И РезультатПроверкиСтатуса.Статус = "success")
        И (ТипОперации <> ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().КоррекцияПрихода
            И ТипОперации <> ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().ВозвратПрихода) Тогда

        ОбщегоНазначенияКлиент.СообщитьПользователю("Чек уже пробит.");

        РезультатФункции.Успех = Ложь;
        РезультатФункции.Результат = РезультатПроверкиСтатуса;

        Возврат РезультатФункции;

    ИначеЕсли РезультатПроверкиСтатуса.Успех = Ложь
        И (ТипОперации = ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().КоррекцияПрихода
            ИЛИ ТипОперации = ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().ВозвратПрихода) Тогда

        ОбщегоНазначенияКлиент.СообщитьПользователю("Чек должен быть зарегистрирован до коррекции/возврата.");
        Возврат РезультатФункции;
    КонецЕсли;

    ДанныеДляОтправкиСчетмаш = ГП_СчетмашAPIКлиентСервер.НовыйСтруктураРегистрацииЧескаСчетмаш(Истина);
    ДанныеДляОтправкиСчетмаш.external_id = ТекущаяСтрокаОплаты.external_id;
    ДанныеДляОтправкиСчетмаш.timestamp = Формат(ТекущаяСтрокаОплаты.timestamp, "ДФ='dd.MM.yyyy hh:mm:ss'");

    НайденныеСтрокиРасшифровки = ЭтотОбъект.Объект.РасшифровкаРегистрацийОплат.НайтиСтроки(
            Новый Структура("external_id", ДанныеДляОтправкиСчетмаш.external_id));
    Если НайденныеСтрокиРасшифровки.Количество() > 100 Тогда
        ВызватьИсключение("Ошибка. Количество строк расшифровки чека превышает максимальное количество: (100)");
    КонецЕсли;

    Для Каждого ТекущаяСтрокаРасшифровки Из НайденныеСтрокиРасшифровки Цикл
        СтруктураЭлементаЧека = ГП_СчетмашAPIКлиентСервер.НовыйСтруктураРасшифровкиСтрокиОплатыРегистрацииЧескаСчетмаш(Истина);
        СтруктураЭлементаЧека.name = СокрЛП(ТекущаяСтрокаРасшифровки.ВидУслугиПредставление);
        СтруктураЭлементаЧека.type =
            ГП_СчетмашAPIКлиентСервер.ПолучитьПризнакПредметаРасчетаСчетмашПоЗначению(ТекущаяСтрокаРасшифровки.ПризнакПредметаРасчета);
        СтруктураЭлементаЧека.mode =
            ГП_СчетмашAPIКлиентСервер.ПолучитьПризнакСпособаРасчетаСчетмашПоЗначению(ТекущаяСтрокаРасшифровки.ПризнакСпособаРасчета);
        СтруктураЭлементаЧека.price = ТекущаяСтрокаРасшифровки.Сумма; // Тариф
        СтруктураЭлементаЧека.quantity = 1; // Количество
        СтруктураЭлементаЧека.sum = ТекущаяСтрокаРасшифровки.Сумма; // Сумма
        СтруктураЭлементаЧека.tax =
            ГП_СчетмашAPIКлиентСервер.ПолучитьСтавкуНДССчетмашПоЗначению(ТекущаяСтрокаРасшифровки.СтавкаНДС); // СтавкаНДС
        СтруктураЭлементаЧека.tax_sum = Окр(УчетНДСКлиентСервер.РассчитатьСуммуНДС(ТекущаяСтрокаРасшифровки.Сумма,
                    Истина, ТекущаяСтрокаРасшифровки.ЗначениеСтавкиНДС), 2); // Сумма НДС

        ДанныеДляОтправкиСчетмаш.receipt.items.Добавить(СтруктураЭлементаЧека);
    КонецЦикла;

    ДанныеДляОтправкиСчетмаш.receipt.total = ТекущаяСтрокаОплаты.Сумма; // Сумма чека

    СтруктураСтрокиОплатыРегистрацииЧеска = ГП_СчетмашAPIКлиентСервер.НовыйСтруктураСтрокиОплатыРегистрацииЧескаСчетмаш(Истина);
    СтруктураСтрокиОплатыРегистрацииЧеска.sum = ТекущаяСтрокаРасшифровки.Сумма;
    ДанныеДляОтправкиСчетмаш.receipt.payments.Добавить(СтруктураСтрокиОплатыРегистрацииЧеска);

    РезультатРегистрацииЧека = ВыполнитьРегистрациюЧекаНаСервере(
            ДанныеДляОтправкиСчетмаш, ТипОперации, ЭтотОбъект.Объект.ИдентификаторМагазина, ЭтотОбъект.Объект.Логин);

    Если РезультатРегистрацииЧека.Успех = Ложь Тогда
        РезультатФункции.Успех = Ложь;
        ОбщегоНазначенияКлиент.СообщитьПользователю(РезультатРегистрацииЧека.ТекстСообщения);
        Возврат РезультатФункции; // Ошибка регистрации чека
    КонецЕсли;

    ТекущаяСтрокаОплаты.id_Чека = РезультатРегистрацииЧека.ДанныеОтвета.Идентификатор;
    ТекущаяСтрокаОплаты.status = РезультатРегистрацииЧека.ДанныеОтвета.Статус;

    Состояние("Регистрация чека выполнена успешно");

    РезультатФункции.Результат = РезультатРегистрацииЧека.ДанныеОтвета;

    Возврат РезультатФункции;
КонецФункции

&НаКлиенте
Функция ВозвратПриходаЧекаСчетмаш(ТекущаяСтрокаОплаты)
    ТипОперации = ГП_СчетмашAPIКлиентСервер.НовыйТипыОперацииРегистрацииЧека().ВозвратПрихода;
    Возврат ПробитьЧекСчетмаш(ТипОперации, ТекущаяСтрокаОплаты);
КонецФункции

&НаСервереБезКонтекста
Функция ВыполнитьРегистрациюЧекаНаСервере(
        Знач ДанныеДляОтправкиСчетмаш, Знач ТипОперации, Знач ИдентификаторМагазина, Знач Логин)

    РезультатРегистрацииЧека = ГП_СчетмашAPI.ВыполнитьРегистрациюЧека(
            ДанныеДляОтправкиСчетмаш, ТипОперации, ИдентификаторМагазина, Логин);
    Возврат РезультатРегистрацииЧека;
КонецФункции

&НаКлиенте
Функция ПроверитьСтатусаЧека(Знач ТекущаяСтрокаОплаты, Знач ВыводитьСообщения = Истина)
    РезультатПроверкиСтатуса = ПолучитьСтатусЧекаСчетмашНаСервере(
            Новый Структура("external_id", ТекущаяСтрокаОплаты.external_id),
            ЭтотОбъект.Объект.ИдентификаторМагазина,
            ЭтотОбъект.Объект.Логин,
            ВыводитьСообщения);

    Если РезультатПроверкиСтатуса.Успех = Ложь Тогда
        ТекущаяСтрокаОплаты.status = РезультатПроверкиСтатуса.Статус;
        ТекущаяСтрокаОплаты.id_Чека = РезультатПроверкиСтатуса.Идентификатор;
        ТекущаяСтрокаОплаты.total = 0;

        Возврат РезультатПроверкиСтатуса;
    КонецЕсли;

    ТекущаяСтрокаОплаты.status = РезультатПроверкиСтатуса.Статус;
    ТекущаяСтрокаОплаты.id_Чека = РезультатПроверкиСтатуса.Идентификатор;
    ТекущаяСтрокаОплаты.total = ?(РезультатПроверкиСтатуса.РеквизитыФискализацииДокумента.СуммаЧека = Неопределено,
            0, РезультатПроверкиСтатуса.РеквизитыФискализацииДокумента.СуммаЧека);

    Возврат РезультатПроверкиСтатуса;
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьСтатусЧекаСчетмашНаСервере(
        Знач СтруктураИдентификатора, Знач ИдентификаторМагазина, Знач Логин, Знач ВыводитьСообщения = Истина)

    РезультатФункции = Новый Структура("Успех, ТекстСообщения, Статус, Идентификатор, МоментВремени, РеквизитыФискализацииДокумента");

    РезультатПроверкиСтатуса = ГП_СчетмашAPI.ПолучитьСтатусЧекаСчетмаш(
            СтруктураИдентификатора, ИдентификаторМагазина, Логин);

    РезультатФункции.Успех = РезультатПроверкиСтатуса.Успех;

    Если РезультатПроверкиСтатуса.Успех = Ложь Тогда
        Если ВыводитьСообщения = Истина
                И РезультатПроверкиСтатуса.Свойство("ДанныеОтвета")
                И РезультатПроверкиСтатуса.ДанныеОтвета.КодОшибки <> 8 Тогда
            ОбщегоНазначения.СообщитьПользователю(РезультатПроверкиСтатуса.ТекстСообщения);
        КонецЕсли;

        Если РезультатПроверкиСтатуса.Свойство("Статус") Тогда
            РезультатФункции.Статус = РезультатПроверкиСтатуса.Статус;
        КонецЕсли;
        Если РезультатПроверкиСтатуса.Свойство("Идентификатор") Тогда
            РезультатФункции.Идентификатор = РезультатПроверкиСтатуса.Идентификатор;
        КонецЕсли;

        РезультатФункции.Успех = Ложь;
        РезультатФункции.ТекстСообщения = РезультатПроверкиСтатуса.ТекстСообщения;
        Возврат РезультатФункции;
    КонецЕсли;

    РезультатФункции.Идентификатор = РезультатПроверкиСтатуса.ДанныеОтвета.Идентификатор;
    РезультатФункции.Статус = РезультатПроверкиСтатуса.ДанныеОтвета.Статус;

    РезультатФункции.РеквизитыФискализацииДокумента = Новый Структура;
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "СуммаЧека", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "total"));
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "НомерЧекаВСмене", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "fiscal_receipt_number"));
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "НомерСмены", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "shift_number"));
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "ДатаДокументаИзФН", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "receipt_datetime"));
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "НомерФН", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "fn_number"));
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "НомерККТ", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "ecr_registration_number"));
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "ФискальныйНомерДокумента", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "fiscal_document_number"));
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "ФискальныйПризнакДокумента", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "fiscal_document_attribute"));
    РезультатФункции.РеквизитыФискализацииДокумента.Вставить(
        "АдресСайтаФНС", ПолучитьЗначениеСвойстваНаСервере(
            РезультатПроверкиСтатуса.ДанныеОтвета.Данные, "fns_site"));

    Возврат РезультатФункции;
КонецФункции

#КонецОбласти // РаботаСЧеками

&НаСервереБезКонтекста
Функция ПолучитьЗначениеСвойстваНаСервере(Знач Контейнер, Знач Ключ, Знач ЗначениеПоУмолчанию = Неопределено)
    РезультатФункции = ЗначениеПоУмолчанию;
    Попытка
        РезультатФункции = Контейнер[Ключ];
    Исключение
        РезультатФункции = ЗначениеПоУмолчанию;
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции

&НаСервере
Процедура УстановитьРежимРаботыНаСервере(Знач ТестовыйРежим)
    Если ТестовыйРежим = Истина Тогда
        ПользовательСчетмаш = ГП_СчетмашAPI.ПолучитьДемоПользователяСчетмаш();
        Если ГП_СчетмашAPI.ЭтоДемоЛогинСчетмаш(ПользовательСчетмаш.Логин) Тогда
            ЭтотОбъект.Объект.Логин = ПользовательСчетмаш.Логин;
            ЭтотОбъект.Объект.ИдентификаторМагазина = 42;

            ЭтотОбъект.Объект.УстановленТестовыйРежимРаботы = Истина;
            ЭтотОбъект.Элементы.ДекорацияРежимДоступа.Заголовок = "ТЕСТОВЫЙ РЕЖИМ";
            ЭтотОбъект.Элементы.ДекорацияРежимДоступа.ЦветТекста = ЦветаСтиля.ПоясняющийОшибкуТекст;

            ОбщегоНазначения.СообщитьПользователю("ВНИМАНИЕ!!! ВКЛЮЧЕН ТЕСТОВЫЙ РЕЖИМ!");
        Иначе
            ВызватьИсключение("Ошибка при установке ТЕСТОВОГО доступа.");
        КонецЕсли;

    Иначе
        ПользовательСчетмаш = ГП_СчетмашAPI.ПолучитьОсновногоПользователяСчетмаш();
        Если НЕ ГП_СчетмашAPI.ЭтоДемоЛогинСчетмаш(ПользовательСчетмаш.Логин) Тогда
            ЭтотОбъект.Объект.Логин = ПользовательСчетмаш.Логин;
            ЭтотОбъект.Объект.ИдентификаторМагазина = 59;

            ЭтотОбъект.Объект.УстановленТестовыйРежимРаботы = Ложь;
            ЭтотОбъект.Элементы.ДекорацияРежимДоступа.Заголовок = "ОНЛАЙН (РАБОЧИЙ)";
            ЭтотОбъект.Элементы.ДекорацияРежимДоступа.ЦветТекста = ЦветаСтиля.ЦветАкцента;

        Иначе
            ВызватьИсключение("Ошибка при установке ОСНОВНОГО (РАБОЧЕГО) доступа.");
        КонецЕсли;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // СлужебныеПроцедурыИФункции
