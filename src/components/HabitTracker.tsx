import { useHabits } from '../context/HabitContext';
import { WeekNavigation } from './WeekNavigation';
import { DayHeader } from './DayHeader';
import { HabitRow } from './HabitRow';
import { HabitForm } from './HabitForm';

export function HabitTracker() {
  const { state } = useHabits();
  const { habits, currentWeekStart } = state;

  return (
    <div className="max-w-4xl mx-auto p-6">
      <header className="text-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Weekly Habit Tracker</h1>
        <p className="text-gray-500">Build better habits, one week at a time</p>
      </header>

      <div className="bg-white rounded-xl shadow-lg p-6">
        <WeekNavigation />

        <DayHeader weekStart={currentWeekStart} />

        <div className="mb-6">
          {habits.length === 0 ? (
            <div className="text-center py-12 text-gray-400">
              <svg
                className="w-16 h-16 mx-auto mb-4 opacity-50"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
                />
              </svg>
              <p className="text-lg">No habits yet</p>
              <p className="text-sm">Add your first habit to get started!</p>
            </div>
          ) : (
            habits.map((habit) => <HabitRow key={habit.id} habit={habit} />)
          )}
        </div>

        <HabitForm />
      </div>

      <footer className="text-center mt-8 text-sm text-gray-400">
        Your progress is saved locally in your browser
      </footer>
    </div>
  );
}
