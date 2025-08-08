export function getFormattedDate(language: string, date: Date): string {
    const locale = language === "es" ? "es-ES" : "en-US";
    return new Intl.DateTimeFormat(locale, {
        year: "2-digit",
        month: "2-digit",
        day: "2-digit",
    }).format(date);
}