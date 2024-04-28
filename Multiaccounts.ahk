#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;Menu, Tray, Icon, imageres.dll, 12

; ПОСТОЯННЫЕ 
DELAY_BETWEEN_PI := 1000 ; задержка между запросом /pi игроков в тг
DAYS_FOR_NOT_ACTIVE_ACCS := 40 ; от скольки дней считать, что аккаунт неактивен

;Step_4()
;Return
Step_1()
Return


Step_1() ; Окно для  вставки текста с /ip ник
{
	msgbox, 4,, % "Перейди в TG и скопируй ответ бота на /ip, после чего нажми на кнопку (при этом нужно остаться в беседе TG с ботом) «Да» для продолжения.`nЕсли нажать «Нет», программа будет завершена."
	ifMsgBox Yes
	{
		str := Clipboard
		Step_2(str)
	Return
	}
	Else
	{
		ExitApp
	}
}


Step_2(Step1_str) ; Обработка вставленного текста
{
	arr := StrSplit(Step1_str, "`r`n", " ")
	accounts_arr := []
	for index, elem in arr
	{
		if (elem = "" or InStr(elem, "#") or InStr(elem, " ") )
		{
			Continue
		}
		accounts_arr.Push(elem)
	}
	Step_3(accounts_arr)
	Return
/*
	msgbox, 4,, % "Обработка завершена!`nПерейди в ТГ и нажми на кнопку «Да» для продолжения. `nЕсли нажать «Нет», программа будет завершена."
	ifMsgBox Yes
	{
		Step_3(accounts_arr)
		Return
	}
	Else
	{
		ExitApp
	}
*/
}

Step_3(accounts_arr) ; запрос /pi всех игроков в списке
{
	Global DELAY_BETWEEN_PI
	sleep, 150
	sendinput, {LButton Down}
	sleep, 100
	sendinput, {LButton Up}
	sleep, 150
	accounts_arr_len := accounts_arr.MaxIndex()
	for index, elem in accounts_arr
	{
		sendinput, {/}
		sleep, 150
		sendinput, pi %elem%
		sleep, 150
		sendinput, {Enter}
		sleep, 150
		if (index = accounts_arr_len)
			Break
		
		Sleep, DELAY_BETWEEN_PI
	}
	sleep, 1000
	msgbox, 4,, % "Запрос /pi завершен!`nВыдели все ответы бота (через функцию TG Выделить), скопируй как текст (ctrl+c) и нажми на кнопку «Да» для продолжения.`nЕсли нажать «Нет», программа будет завершена."
	ifMsgBox Yes
	{
		Step_4()
		Return
	}
	Else
	{
		ExitApp
	}
}

Step_4() ; выбраковка неактивных акков, удаление ненужных данных
{
	Step4_str := clipboard
	pi_arr := StrSplit(Step4_str, "`r`n`r`n")
	output_arr := []
	for index, elem in pi_arr
	{
		;msgbox, %elem%
		pi_strings := StrSplit(elem, "`r`n")
		pi_strings.RemoveAt(1, 1)
		first_elem := pi_strings[1]
		if (!InStr(first_elem, "Об игроке:"))
		{
			OfferReload("Неверный формат данных! Чтобы правильно выделить информацию, кликни правой кнопкой мыши по любому сообщению, которое прислал бот тебе в ЛС, нажми «Выделить», выдели все сообщения с нужной информацией, ctrl+c")
			Return
		}
		modified_pi_strings := []
		strings_to_search := ["● Ник:", "● Последний вход:", "● Регистрация:", "● Наиграно:", "● Наказания:"]
		accept_all := 0
		for pi_string_index, pi_string in pi_strings
		{
			if (accept_all)
			{
				modified_pi_strings.Push(pi_string)
				Continue
			}
			for search_string_index, search_string in strings_to_search
			{
				if (Instr(pi_string, search_string))
				{
					if (search_string = "● Наказания:")
					{
						if (Instr(pi_string, "-")) ; наказаний нет
						{
							Break
						}
						Else
						{
							accept_all := 1
						}
						
					}
					Else If (search_string = "● Последний вход:")
					{
						last_entry_arr := StrSplit(pi_string, " д ", "● Последний вход: ")
						last_entry_days := 0
						if (last_entry_arr.MaxIndex() = 2)
						{
							last_entry_days := last_entry_arr[1]
							last_entry_days := last_entry_days + 0
						}	
						Global DAYS_FOR_NOT_ACTIVE_ACCS
						if (last_entry_days >= DAYS_FOR_NOT_ACTIVE_ACCS)
						{
							Goto, SkipPi
						}
					}
					modified_pi_strings.Push(pi_string)
					Break
				}
			}		
		}
		
		pi_modified := Join(modified_pi_strings, "`n")
		;msgbox, % pi_modified
		output_arr.Push(pi_modified)
		SkipPi:
	}
	Step_5(output_arr)
	Return
}

Step_5(arr) ; окно с результатом
{
	string := Join(arr, "`n`n")
	Gui, Add, Edit, w300 h600, %string%
	;Gui, Add, Button, gStep1 Default, OK
	Gui, Show
}

GuiClose:
OfferReload()
Return


OfferReload(str := "") ; Предложить начать заново
{
	if (str != "")
		str := str "`n"
	msgbox, 4,, % str "Хочешь начать заново? Если нажать «Нет», программа будет завершена."
	ifMsgBox Yes
	{
		Reload
	}
	Else
	{
		ExitApp
	}
}




Index(search_value, arr) ; поиск элемента массива по значению (строка поиска должна быть равной элементу), возвращает индекс элемента
{
	for key, val in arr
	{
		if (val = search_value)
		{
			return %key%
		}
	}
	return 0
}

Search(search_value, arr) ; поиск элемента массива по значению (строка поиска должна быть внутри элемента), возвращает индекс элемента
{
	for key, val in arr
	{
		if (Instr(val, search_value))
		{
			return %key%
		}
	}
	return 0
}

Join(arr, sep) ; соеденить массив в строку (sep - символ между элементами для соединения)
{
	result := ""
	first := true

	Loop, % arr.MaxIndex()
	{
	  if (first)
	  {
		result := arr[A_Index]
		first := false
	  }
	  else
	  {
		result := result . sep . arr[A_Index]
	  }
	}
	return result
}