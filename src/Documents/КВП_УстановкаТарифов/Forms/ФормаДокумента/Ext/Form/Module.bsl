﻿// Гарант+ Килипенко 17.09.2024 [F00228438] Вид тарифа потребителя для Установки тарифа ++
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ГП_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
    // Создание элементов формы
    ГП_СоздатьПолеВидТарифаПотребителя();
    ГП_СоздатьКомандуНачисленияПоПоказаниям();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы
// Гарант+ Килипенко 17.09.2024 [F00228438] Вид тарифа потребителя для Установки тарифа --

#Область ОбработчикиКомандФормы

// Создает документ ввода показаний счетчиков по текущей строке списка (с отбором по договору л/с текущей строки)
&НаКлиенте
Асинх Процедура ГП_ЗаполнитьПоВидуТарифаПотребителяПриНажатии(Команда)
    // Проверка исходных данных для заполнения
    Если ЗначениеЗаполнено(ЭтотОбъект.Объект.ГП_ВидТарифаПотребителя) = Ложь Тогда
        ОбщегоНазначенияКлиент.СообщитьПользователю("Не указан вид тарифа потребителя.");
        Возврат;
    КонецЕсли;
    Если ЗначениеЗаполнено(ЭтотОбъект.Объект.Услуга) = Ложь Тогда
        ОбщегоНазначенияКлиент.СообщитьПользователю("Не выбрана услуга.");
        Возврат;
    КонецЕсли;

    // Предупреждение пользователю о перезаписи таблицы
    Если ЭтотОбъект.Объект.СписокОбъектов.Количество() > 0 Тогда
        РезультатДиалога = Ждать ГП_ОбщегоНазначенияКлиент.СпроситьПользователяОГотовностиВыполнятьОперациюАсинх(
                "Таблица объектов будет перезаписана.");
        Если РезультатДиалога = Ложь Тогда
            Возврат; // Пользователь отказался от выполнения операции
        КонецЕсли;
    КонецЕсли;

    // Дата актуальности для отбора помещений
    ДатаАктуальности = Неопределено;
    Если ЗначениеЗаполнено(ЭтотОбъект.Объект.Дата) Тогда
        ДатаАктуальности = ЭтотОбъект.Объект.Дата;
    КонецЕсли;

    ЗаполнитьСписокОбъектовПоВидуТарифаНаСервере(ДатаАктуальности, ЭтотОбъект.Объект.Услуга, ЭтотОбъект.Объект.ГП_ВидТарифаПотребителя);
КонецПроцедуры

#КонецОбласти // ОбработчикиКомандФормы

// Гарант+ Килипенко 17.09.2024 [F00228438] Вид тарифа потребителя для Установки тарифа ++
#Область СлужебныеПроцедурыИФункции

#Область ПереопределениеСтандартногоФункционала

&НаКлиентеНаСервереБезКонтекста
&ИзменениеИКонтроль("УстановитьВидыТарифов")
Процедура ГП_УстановитьВидыТарифов(Форма)

    Элементы = Форма.Элементы;
    Объект   = Форма.Объект;

    Элементы.СписокУслугТариф.Заголовок = "Тариф";

    СпВидовТарифов = Новый СписокЗначений();

    СпособРасчетаУслуги = УПЖКХ_ОбщегоНазначенияСервер.ПолучитьЗначениеРеквизита(Объект.Услуга, "СпособРасчета");

    Если НЕ Объект.Услуга.Пустая() Тогда
        Если СпособРасчетаУслуги = ПредопределенноеЗначение(
            "Перечисление.КВП_СпособыРасчета.ПоПоказаниямСчетчика")
            ИЛИ СпособРасчетаУслуги = ПредопределенноеЗначение(
            "Перечисление.КВП_СпособыРасчета.ПоПоказаниямСчетчикаИНорме") Тогда
            СпВидовТарифов.Добавить(ПредопределенноеЗначение("Перечисление.КВП_ВидыТарифов.Дневной"));
            #Удаление // Гарант+ Килипенко 03.12.2024 [F00231908] Доработка документа установка тарифа
            СпВидовТарифов.Добавить(ПредопределенноеЗначение("Перечисление.КВП_ВидыТарифов.Ночной"));
            СпВидовТарифов.Добавить(ПредопределенноеЗначение("Перечисление.КВП_ВидыТарифов.Пиковый"));
            #КонецУдаления
            СпВидовТарифов.Добавить(ПредопределенноеЗначение("Перечисление.КВП_ВидыТарифов.Общий"));
        ИначеЕсли СпособРасчетаУслуги = ПредопределенноеЗначение("Перечисление.КВП_СпособыРасчета.КомиссияБанка") Тогда
            СпВидовТарифов.Добавить(ПредопределенноеЗначение("Перечисление.КВП_ВидыТарифов.КомиссияБанка"));
            Элементы.СписокУслугТариф.Заголовок = "Процент";
        Иначе
            СпВидовТарифов.Добавить(ПредопределенноеЗначение("Перечисление.КВП_ВидыТарифов.Общий"));
        КонецЕсли;

        мНастройкиУчетнойПолитикиТСЖ =
        УПЖКХ_ОбщегоНазначенияСервер.ПолучитьПараметрыУчетнойПолитикиЖКХ(Объект.Дата, Объект.Организация);
        Если мНастройкиУчетнойПолитикиТСЖ.ИспользоватьЛьготныйТариф Тогда
            СпВидовТарифов.Добавить(ПредопределенноеЗначение("Перечисление.КВП_ВидыТарифов.Льготный"));
        КонецЕсли;
    КонецЕсли;

    Элементы.СписокУслугВидТарифа.СписокВыбора.Очистить();
    Для Каждого ТекЗначениеВыбора Из СпВидовТарифов Цикл
        Элементы.СписокУслугВидТарифа.СписокВыбора.Добавить(ТекЗначениеВыбора.Значение);
    КонецЦикла;

КонецПроцедуры

#КонецОбласти // ПереопределениеСтандартногоФункционала

&НаСервере
Функция ГП_СоздатьПолеВидТарифаПотребителя()
    ПолеВидТарифаПотребителя = ЭтотОбъект.Элементы.Добавить(
            "ГП_ВидТарифаПотребителя",
            Тип("ПолеФормы"),
            ЭтотОбъект.Элементы.ГруппаСправа);
    ПолеВидТарифаПотребителя.Вид = ВидПоляФормы.ПолеВвода;
    ПолеВидТарифаПотребителя.ПутьКДанным = "Объект.ГП_ВидТарифаПотребителя";

    Возврат ПолеВидТарифаПотребителя;
КонецФункции

// Создает кнопку формы Заполнить объекты по Виду тарифа потребителя
// Возвращаемое значение:
//  - Структура
//      * Кнопка
//      * Команда
&НаСервере
Функция ГП_СоздатьКомандуНачисленияПоПоказаниям()
    Результат = Новый Структура("Кнопка, Команда");

    // Создание команды формы
    Результат.Команда = ЭтотОбъект.Команды.Добавить("ГП_ЗаполнитьПоВидуТарифаПотребителя");
    Результат.Команда.Заголовок = "Заполнить по виду тарифа";
    Результат.Команда.Действие = "ГП_ЗаполнитьПоВидуТарифаПотребителяПриНажатии";

    // Создание элемента формы
    Результат.Кнопка = ЭтотОбъект.Элементы.Добавить(
            "ГП_ЗаполнитьПоВидуТарифаПотребителя",
            Тип("КнопкаФормы"),
            ЭтотОбъект.Элементы.СписокОбъектовКоманднаяПанель);
    Результат.Кнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
    Результат.Кнопка.ИмяКоманды = Результат.Команда.Имя;

    Возврат Результат;
КонецФункции

// Выполняет заполнение таблицы объектов абонентов
// Параметры:
//  ДатаАктуальности - Дата, Граница, МоментВремени
//  Услуга - СправочникСсылка.КВП_Услуги
//  ВидТарифаПотребителя - СправочникСсылка.lc_ВидыТарифов
&НаСервере
Процедура ЗаполнитьСписокОбъектовПоВидуТарифаНаСервере(Знач ДатаАктуальности, Знач Услуга, Знач ВидТарифаПотребителя)
    ЭтотОбъект.Объект.СписокОбъектов.Очистить();

    // Формирование параметров отбора помещений
    ПараметрыОтбораПомещений = Новый Структура("Услуга, ВидТарифаПотребителя", Услуга, ВидТарифаПотребителя);
    Если ДатаАктуальности <> Неопределено Тогда
        Если ТипЗнч(ДатаАктуальности) = Тип("Дата") Тогда
            ДатаАктуальности = Новый Граница(Новый МоментВремени(ДатаАктуальности, Неопределено), ВидГраницы.Включая);
        КонецЕсли;

        ПараметрыОтбораПомещений.Вставить("ДатаАктуальности", ДатаАктуальности);
    КонецЕсли;

    // Отбор помещений для заполнения
    ДанныеДляЗаполнения = ГП_РаботаСТарифами.ПолучитьПомещенияДляУстановкиТарифов(ПараметрыОтбораПомещений);

    // Заполнение таблицы объектов
    Для Каждого СтрокаДанных Из ДанныеДляЗаполнения Цикл
        НоваяСтрокаОбъектов = ЭтотОбъект.Объект.СписокОбъектов.Добавить();
        НоваяСтрокаОбъектов.Здание = СтрокаДанных.Здание;
        НоваяСтрокаОбъектов.Помещение = СтрокаДанных.Помещение;
    КонецЦикла;

    ЭтотОбъект.Модифицированность = Истина;
КонецПроцедуры

#КонецОбласти // СлужебныеПроцедурыИФункции
// Гарант+ Килипенко 17.09.2024 [F00228438] Вид тарифа потребителя для Установки тарифа --
