(function () {
  function getLocale() {
    return document.documentElement.lang || 'de-DE';
  }

  function formatLocalizedDate(date) {
    const formatter = new Intl.DateTimeFormat(getLocale(), {
      weekday: 'long',
      day: '2-digit',
      month: '2-digit'
    });
    return formatter.format(date);
  }

  function getNthWeekdayOfMonth(year, monthIndex, weekday, occurrence) {
    const firstDay = new Date(year, monthIndex, 1);
    const firstWeekdayOffset = (weekday - firstDay.getDay() + 7) % 7;
    const day = 1 + firstWeekdayOffset + (occurrence - 1) * 7;
    return new Date(year, monthIndex, day);
  }

  function getNextOccurrences({ weekday, occurrence, count, from = new Date() }) {
    const results = [];
    let year = from.getFullYear();
    let month = from.getMonth();

    while (results.length < count) {
      const candidate = getNthWeekdayOfMonth(year, month, weekday, occurrence);
      if (candidate >= from) {
        results.push(candidate);
      }

      month += 1;
      if (month > 11) {
        month = 0;
        year += 1;
      }
    }

    return results;
  }

  function populateList(listId, config) {
    const list = document.getElementById(listId);
    if (!list) {
      return;
    }

    const dates = getNextOccurrences(config);
    list.innerHTML = dates
      .map((date) => `<li>${config.label(date)}</li>`)
      .join('');
  }

  populateList('mannheim-next-dates', {
    weekday: 3,
    occurrence: 2,
    count: 4,
    label(date) {
      return formatLocalizedDate(date);
    }
  });
})();
