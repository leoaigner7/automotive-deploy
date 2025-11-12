export default function AppLayout({ children }) {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-neutral-900 text-gray-900 dark:text-gray-100 flex flex-col transition-colors">
      <header className="h-14 border-b border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800 px-4 flex items-center justify-between">
        <div className="font-semibold text-blue-600">Automotive Deploy v2</div>
        <div className="text-sm opacity-70">Schöner • Schneller • Mehr Features</div>
      </header>
      <div className="flex flex-1">
        <aside className="w-64 border-r border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800 p-4 space-y-2">
          <a href="/" className="block px-3 py-2 rounded hover:bg-gray-100 dark:hover:bg-neutral-700">Dashboard</a>
          <a href="/vehicles" className="block px-3 py-2 rounded hover:bg-gray-100 dark:hover:bg-neutral-700">Fahrzeuge</a>
          <a href="/status" className="block px-3 py-2 rounded hover:bg-gray-100 dark:hover:bg-neutral-700">Status</a>
        </aside>
        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  );
}

