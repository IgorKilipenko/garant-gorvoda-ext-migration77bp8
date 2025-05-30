﻿#Область ПрограммныйИнтерфейс

// Выполняет замену незаполненного значения водозабора в динамических показателях на элемент БезВодозабора
//  только если л/с имеет счетчик (хотя бы один) с признаком `ГП_ТолькоДляКанализации`
// Параметры:
//  ДатаАктуальности - Дата, Неопределено
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * ТекстСообщения - Строка
//      * КоличествоЗаписей - Число
Функция ЗаполнитьДинамическиеПоказателиЛицевыхСчетовСПустымВодозабором(Знач ДатаАктуальности = Неопределено) Экспорт
    РезультатФункции = Новый Структура("Успех, КоличествоЗаписей, ТекстСообщения", Истина, 0);

    ДанныеЗаполнения = ПолучитьЛицевыеСчетаБезНазначенногоВодозабора(ДатаАктуальности, Истина, Истина);

    ВодозаборЗамены = ПолучитьВодозаборБезВодозабора().Ссылка;

    НачатьТранзакцию();
    Попытка
        Для Каждого СтрокаДанных Из ДанныеЗаполнения Цикл
            НаборЗаписейДинамическихПоказателей = РегистрыСведений.lc_ДинамическиеПоказателиЛицевыхСчетов.СоздатьНаборЗаписей();
            НаборЗаписейДинамическихПоказателей.Отбор.Период.Установить(СтрокаДанных.ПериодПоказателя);
            НаборЗаписейДинамическихПоказателей.Отбор.ЛицевойСчет.Установить(СтрокаДанных.ЛицевойСчет);
            НаборЗаписейДинамическихПоказателей.Прочитать();

            ТребуетсяЗаписьНабора = Ложь;
            Для Каждого СтрокаПоказателей Из НаборЗаписейДинамическихПоказателей Цикл
                Если СтрокаПоказателей.Водозабор <> ВодозаборЗамены Тогда
                    ТребуетсяЗаписьНабора = Истина;
                    СтрокаПоказателей.Водозабор = ВодозаборЗамены;

                    РезультатФункции.КоличествоЗаписей = РезультатФункции.КоличествоЗаписей + 1;
                КонецЕсли;
            КонецЦикла;

            Если ТребуетсяЗаписьНабора = Истина Тогда
                НаборЗаписейДинамическихПоказателей.Записать(Истина);
            КонецЕсли;
        КонецЦикла;

        ЗафиксироватьТранзакцию();
    Исключение
        ОтменитьТранзакцию();

        РезультатФункции.Успех = Ложь;
        РезультатФункции.КоличествоЗаписей = 0;
        РезультатФункции.ТекстСообщения = СтрШаблон(
                "Ошибка при записи динамических показателей.
                |Информация: %1", ОбработкаОшибок.ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
    КонецПопытки;

    Возврат РезультатФункции;
КонецФункции

// Теплоснабжающие орг-ции
// Возвращаемое значение:
//  - Структура
//      * Ссылка - СправочникСсылка.lc_Водозаборы
//      * Код - Строка
//      * Наименование - Строка
Функция ПолучитьВодозаборБезВодозабора() Экспорт
    Возврат ПолучитьВодозаборПоКоду("000000033", Истина);
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныйПрограммныйИнтерфейс

// Параметры:
//  Код - Строка
//  ИгнорироватьПомеченныеНаУдаление - Булево
// Возвращаемое значение:
//  - Структура
//      * Ссылка - СправочникСсылка.lc_Водозаборы
//      * Код - Строка
//      * Наименование - Строка
Функция ПолучитьВодозаборПоКоду(Знач Код, Знач ИгнорироватьПомеченныеНаУдаление = Истина) Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |   Водозаборы.Ссылка КАК Ссылка,
        |   Водозаборы.Код КАК Код,
        |   Водозаборы.Наименование КАК Наименование
        |ИЗ
        |   Справочник.lc_Водозаборы КАК Водозаборы
        |ГДЕ
        |   Водозаборы.Код = &Код
        |   И Водозаборы.ПометкаУдаления = ЛОЖЬ
        |";

    Запрос.УстановитьПараметр("Код", Код);
    Если ИгнорироватьПомеченныеНаУдаление = Ложь Тогда
        Запрос.Текст = СтрЗаменить(Запрос.Текст, "И lc_Водозаборы.ПометкаУдаления = ЛОЖЬ", "");
    КонецЕсли;

    РезультатЗапроса = Запрос.Выполнить();
    ТаблицаВидовТарифов = РезультатЗапроса.Выгрузить();

    Если ТаблицаВидовТарифов.Количество() <> 1 Тогда
        ВызватьИсключение(СтрШаблон("Ошибка при получении водозабора с кодом ""%1"". %2",
                Код,
                ?(ТаблицаВидовТарифов.Количество() > 1, "Код водозабора не уникален.", "Водозабора отсутствует в ИБ.")));
    КонецЕсли;

    РезультатФункции = Новый Структура("Ссылка, Код, Наименование");
    ЗаполнитьЗначенияСвойств(РезультатФункции, ТаблицаВидовТарифов[0]);

    Возврат РезультатФункции;
КонецФункции

// Параметры:
//  ДатаАктуальности - Дата, Неопределено
//  ТолькоИмеющиеСчетчикТолькоДляКанализации - Булево
//  ПоДаннымБП77 - Булево - Если Истина, то данные признака ТолькоДляКанализации берутся из РС.ГП_ЗданияБП77 иначе по данным счетчиков
// Возвращаемое значение:
//  - ТаблицаЗначений
//      * ЛицевойСчет - СправочникСсылка.КВП_ЛицевыеСчета
//      * ПериодПоказателя - Дата
//      * ЕстьСчетчикТолькоДляКанализации - Булево
Функция ПолучитьЛицевыеСчетаБезНазначенногоВодозабора(
        Знач ДатаАктуальности = Неопределено, ТолькоИмеющиеСчетчикТолькоДляКанализации = Ложь, ПоДаннымБП77 = Ложь) Экспорт

    Запрос = Новый Запрос;
    Если ПоДаннымБП77 = Ложь Тогда
        Запрос.Текст =
            "ВЫБРАТЬ РАЗРЕШЕННЫЕ
            |	ДинамическиеПоказателиЛицевыхСчетов.Период КАК Период,
            |	ДинамическиеПоказателиЛицевыхСчетов.ЛицевойСчет КАК ЛицевойСчет,
            |	ДинамическиеПоказателиЛицевыхСчетов.Водозабор КАК Водозабор
            |ПОМЕСТИТЬ ВТ_ЛицевыеСчетаБезВодозаборов
            |ИЗ
            |	РегистрСведений.lc_ДинамическиеПоказателиЛицевыхСчетов.СрезПоследних(&ДатаАктуальности, ) КАК ДинамическиеПоказателиЛицевыхСчетов
            |ГДЕ
            |	ДинамическиеПоказателиЛицевыхСчетов.Водозабор = ЗНАЧЕНИЕ(Справочник.lc_Водозаборы.ПустаяСсылка)
            |;
            |
            |////////////////////////////////////////////////////////////////////////////////
            |ВЫБРАТЬ РАЗРЕШЕННЫЕ
            |	ВЫРАЗИТЬ(ИсторияСостоянийПриборовУчета.Объект КАК Справочник.КВП_ЛицевыеСчета) КАК ЛицевойСчет,
            |	МАКСИМУМ(ВТ_ЛицевыеСчетаБезВодозаборов.Период) КАК ПериодПоказателя,
            |	МАКСИМУМ(ИсторияСостоянийПриборовУчета.ПриборУчета.ГП_ТолькоДляКанализации) КАК ЕстьСчетчикТолькоДляКанализации
            |ИЗ
            |	РегистрСведений.УПЖКХ_ИсторияСостоянийПриборовУчета.СрезПоследних(&ДатаАктуальности, ) КАК ИсторияСостоянийПриборовУчета
            |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ЛицевыеСчетаБезВодозаборов КАК ВТ_ЛицевыеСчетаБезВодозаборов
            |		ПО ((ВЫРАЗИТЬ(ИсторияСостоянийПриборовУчета.Объект КАК Справочник.КВП_ЛицевыеСчета)) = ВТ_ЛицевыеСчетаБезВодозаборов.ЛицевойСчет)
            |ГДЕ
            |	ИсторияСостоянийПриборовУчета.Объект ССЫЛКА Справочник.КВП_ЛицевыеСчета
            |
            |СГРУППИРОВАТЬ ПО
            |	ВЫРАЗИТЬ(ИсторияСостоянийПриборовУчета.Объект КАК Справочник.КВП_ЛицевыеСчета)
            |
            |ИМЕЮЩИЕ
            |	ИСТИНА И
            |	МАКСИМУМ(ИсторияСостоянийПриборовУчета.ПриборУчета.ГП_ТолькоДляКанализации) = ИСТИНА
            |";

    Иначе

        Запрос.Текст =
            "ВЫБРАТЬ РАЗРЕШЕННЫЕ
            |	ДинамическиеПоказателиЛицевыхСчетов.Период КАК Период,
            |	ДинамическиеПоказателиЛицевыхСчетов.ЛицевойСчет КАК ЛицевойСчет,
            |	ДинамическиеПоказателиЛицевыхСчетов.Водозабор КАК Водозабор,
            |	ЗданияБП77.ТолькоДляКанализации КАК ТолькоДляКанализации
            |ПОМЕСТИТЬ ВТ_ЛицевыеСчетаБезВодозаборов
            |ИЗ
            |	РегистрСведений.lc_ДинамическиеПоказателиЛицевыхСчетов.СрезПоследних(&ДатаАктуальности, ) КАК ДинамическиеПоказателиЛицевыхСчетов
            |	ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ГП_ЗданияБП77 КАК ЗданияБП77
            |	ПО ДинамическиеПоказателиЛицевыхСчетов.Водозабор = ЗНАЧЕНИЕ(Справочник.lc_Водозаборы.ПустаяСсылка)
            |	И ЗданияБП77.ТолькоДляКанализации = ИСТИНА
            |	И ДинамическиеПоказателиЛицевыхСчетов.ЛицевойСчет.Идентификатор = ЗданияБП77.ОбъектАбонентаКод + ""_"" + ЗданияБП77.КонтрагентКод
            |ГДЕ
            |	ДинамическиеПоказателиЛицевыхСчетов.Водозабор = ЗНАЧЕНИЕ(Справочник.lc_Водозаборы.ПустаяСсылка)
            |;
            |
            |////////////////////////////////////////////////////////////////////////////////
            |ВЫБРАТЬ РАЗРЕШЕННЫЕ
            |	ВТ_ЛицевыеСчетаБезВодозаборов.ЛицевойСчет КАК ЛицевойСчет,
            |	ВТ_ЛицевыеСчетаБезВодозаборов.Период КАК ПериодПоказателя,
            |	ВТ_ЛицевыеСчетаБезВодозаборов.ТолькоДляКанализации КАК ЕстьСчетчикТолькоДляКанализации
            |ИЗ
            |	ВТ_ЛицевыеСчетаБезВодозаборов КАК ВТ_ЛицевыеСчетаБезВодозаборов
            |";
    КонецЕсли;

    Если ДатаАктуальности = Неопределено Тогда
        Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ДатаАктуальности", "");
    Иначе
        Запрос.УстановитьПараметр("ДатаАктуальности", ДатаАктуальности);
    КонецЕсли;

    Если ТолькоИмеющиеСчетчикТолькоДляКанализации = Ложь Тогда
        Если ПоДаннымБП77 = Ложь Тогда
            Запрос.Текст = СтрЗаменить(Запрос.Текст,
                    "И МАКСИМУМ(ИсторияСостоянийПриборовУчета.ПриборУчета.ГП_ТолькоДляКанализации) = ИСТИНА", "");
        Иначе
            Запрос.Текст = СтрЗаменить(Запрос.Текст, "И ЗданияБП77.ТолькоДляКанализации = ИСТИНА", "");
        КонецЕсли;
    КонецЕсли;

    РезультатЗапроса = Запрос.Выполнить();
    РезультатФункции = РезультатЗапроса.Выгрузить();
    Возврат РезультатФункции;
КонецФункции

#КонецОбласти // СлужебныйПрограммныйИнтерфейс
