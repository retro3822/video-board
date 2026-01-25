import { getWeekDates, getDayName, getDayOfMonth, isToday } from '../utils/dateUtils';

interface DayHeaderProps {
  weekStart: Date;
}

export function DayHeader({ weekStart }: DayHeaderProps) {
  const weekDates = getWeekDates(weekStart);

  return (
    <div className="grid grid-cols-[200px_repeat(7,1fr)] gap-2 mb-2">
      <div className="text-sm font-medium text-gray-500">Habit</div>
      {weekDates.map((date) => (
        <div
          key={date.toISOString()}
          className={`text-center ${isToday(date) ? 'text-indigo-600' : 'text-gray-500'}`}
        >
          <div className="text-xs font-medium">{getDayName(date)}</div>
          <div
            className={`text-sm font-bold ${
              isToday(date)
                ? 'bg-indigo-600 text-white rounded-full w-7 h-7 flex items-center justify-center mx-auto'
                : ''
            }`}
          >
            {getDayOfMonth(date)}
          </div>
        </div>
      ))}
    </div>
  );
}
