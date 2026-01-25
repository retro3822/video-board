import { HabitProvider } from './context/HabitContext';
import { HabitTracker } from './components/HabitTracker';

function App() {
  return (
    <HabitProvider>
      <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50 py-8">
        <HabitTracker />
      </div>
    </HabitProvider>
  );
}

export default App;
