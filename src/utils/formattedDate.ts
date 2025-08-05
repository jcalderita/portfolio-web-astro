export function getFormattedDate(language: string, date: Date): string {
    const locale = language === "es" ? "es-ES" : "en-US";
    return new Intl.DateTimeFormat(locale, {
        year: "numeric",
        month: "long",
        day: "numeric",
    }).format(date);
}