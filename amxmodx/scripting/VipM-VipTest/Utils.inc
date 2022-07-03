stock const __CLANG_TEMPLATE_STR[] = "%L";
stock const __NUM_STR[] = "%d";
stock const __SLANG_TEMPLATE_STR[] = "%l";

#define Lang(%1) \
    fmt(__SLANG_TEMPLATE_STR, %1)

#define IsUserIdValid(%1) \
    (%1 >= 1 && %1 <= 32)

new const LANG_MESSAGE_LAYOUT[] = "VIPM_VIPTEST_MSG_LAYOUT";
#define ChatPrint(%1,%2) \
    client_print_color(%1, print_team_default, __CLANG_TEMPLATE_STR, IsUserIdValid(%1) ? %1 : -1, LANG_MESSAGE_LAYOUT, fmt(%2))

#define ChatPrintL(%1,%2) \
    ChatPrint(%1, __CLANG_TEMPLATE_STR, %1, %2)

#define IntToStr(%1) \
    fmt(__NUM_STR, %1)

stock __nvault_has_TEMP;
#define nvault_has(%1,%2) \
    bool:nvault_lookup(%1, %2, "", 0, __nvault_has_TEMP)

// https://dev-cs.ru/threads/222/page-3#post-33411
// TODO: Добавить как тип параметра в ядро
stock ParseTimeLength(const value[]) {
    new t, k;
    for (new i; value[i] != EOS; i++) {
        switch (value[i]) {
            case '0'..'9': {
                t = (t * 10) + (value[i] - '0');
            }
            case 'i': {
                k += t * 60;
                t = 0;
            }
            case 'h': {
                k += t * 3600;
                t = 0;
            }
            case 'd': {
                k += t * 86400;
                t = 0;
            }
            case 'm': {
                k += t * 2592000;
                t = 0;
            }
            case 'y': {
                k += t * 31104000;
                t = 0;
            }
            default: {
                break;
            }
        }
    }
    return k + t;
}

stock TimeLengthFormat(const iSeconds, sOut[], const iOutLen, const iOutFrom = 0) {
    if (iOutFrom >= iOutLen || iSeconds <= 0) {
        return 0;
    }

    new _iOutFrom = iOutFrom;

    if (_iOutFrom > 0) {
        sOut[_iOutFrom] = ' ';
        _iOutFrom++;
    }

    new const MINUTE_LENGTH = 60;
    new const HOUR_LENGTH = MINUTE_LENGTH * 60;
    new const DAY_LENGTH = HOUR_LENGTH * 24;

    if (iSeconds >= DAY_LENGTH) {
        return _iOutFrom + TimeLengthFormat(
            iSeconds % DAY_LENGTH,
            sOut, iOutLen,
            _iOutFrom + formatex(sOut[_iOutFrom], iOutLen, "%dд", iSeconds / DAY_LENGTH)
        );
    }

    if (iSeconds >= HOUR_LENGTH) {
        return _iOutFrom + TimeLengthFormat(
            iSeconds % HOUR_LENGTH,
            sOut, iOutLen,
            _iOutFrom + formatex(sOut[_iOutFrom], iOutLen, "%dч", iSeconds / HOUR_LENGTH)
        );
    }

    if (iSeconds >= MINUTE_LENGTH) {
        return _iOutFrom + TimeLengthFormat(
            iSeconds % MINUTE_LENGTH,
            sOut, iOutLen,
            _iOutFrom + formatex(sOut[_iOutFrom], iOutLen, "%dмин", iSeconds / MINUTE_LENGTH)
        );
    }

    return _iOutFrom + formatex(sOut[_iOutFrom], iOutLen, "%dсек", iSeconds);
}
