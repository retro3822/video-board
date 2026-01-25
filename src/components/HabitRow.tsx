import { Habit } from '../types/habit';
import { useHabits } from '../context/HabitContext';
import { getWeekDates, formatDate, isToday } from '../utils/dateUtils';

interface HabitRowProps {
  habit: Habit;
}

export function HabitRow({ habit }: HabitRowProps) {
  const { state, dispatch } = useHabits();
  const weekDates = getWeekDates(state.currentWeekStart);

  const handleToggle = (date: string) => {
    dispatch({ type: 'TOGGLE_DAY', payload: { habitId: habit.id, date } });
  };

  const handleDelete = () => {
    if (confirm(`Delete "${habit.name}"?`)) {
      dispatch({ type: 'DELETE_HABIT', payload: habit.id });
    }
  };

  const completedThisWeek = weekDates.filter((date) =>
    habit.completedDates.includes(formatDate(date))
  ).length;

  return (
    <div className="grid grid-cols-[200px_repeat(7,1fr)] gap-2 items-center py-3 border-b border-gray-100 last:border-b-0 group">
      <div className="flex items-center gap-2">
        <div
          className="w-3 h-3 rounded-full flex-shrink-0"
          style={{ backgroundColor: habit.color }}
        />
        <span className="font-medium text-gray-800 truncate">{habit.name}</span>
        <button
          onClick={handleDelete}
          className="opacity-0 group-hover:opacity-100 p-1 hover:bg-red-100 rounded transition-all"
          aria-label="Delete habit"
        >
          <svg
            className="w-4 h-4 text-red-500"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
            />
          </svg>
        </button>
        <span className="ml-auto text-xs text-gray-400">{completedThisWeek}/7</span>
      </div>

      {weekDates.map((date) => {
        const dateStr = formatDate(date);
        const isCompleted = habit.completedDates.includes(dateStr);
        const today = isToday(date);

        return (
          <button
            key={dateStr}
            onClick={() => handleToggle(dateStr)}
            className={`
              w-10 h-10 mx-auto rounded-lg border-2 transition-all duration-200
              flex items-center justify-center
              ${
                isCompleted
                  ? 'border-transparent'
                  : today
                  ? 'border-indigo-300 bg-indigo-50 hover:bg-indigo-100'
                  : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
              }
            `}
            style={isCompleted ? { backgroundColor: habit.color } : undefined}
            aria-label={`${isCompleted ? 'Mark incomplete' : 'Mark complete'} for ${habit.name}`}
          >
            {isCompleted && (
              <svg
                className="w-5 h-5 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={3}
                  d="M5 13l4 4L19 7"
                />
              </svg>
            )}
          </button>
        );
      })}
    </div>
  );
}
