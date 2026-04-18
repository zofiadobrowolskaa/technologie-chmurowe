import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';

const Home = () => <h2>Strona Główna Dashboardu</h2>;

const Products = () => {
    const [items, setItems] = useState([]);
    const [name, setName] = useState('');

    const fetchItems = () =>
        fetch('/api/items')
            .then(res => res.json())
            .then(data => setItems(data.items));
    
    useEffect(() => { fetchItems(); }, []);

    const addProduct = async (e) => {
        e.preventDefault();
        await fetch('/api/items', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name })
        });
        setName('');
        fetchItems();
    };

    return (
        <div>
            <h2>Lista Produktów</h2>
            <ul>
                {items.map(item => <li key={item.id}>{item.name}</li>)}
            </ul>
            <form onSubmit={addProduct}>
                <input
                    value={name}
                    onChange={e => setName(e.target.value)}
                    placeholder="Nazwa produktu"
                    required
                />
                <button type="submit">Dodaj Produkt</button>
            </form>
        </div>
    );
};

const Stats = () => {
    const [stats, setStats] = useState({});

    useEffect(() => {
        fetch('/api/stats')
            .then(res => res.json())
            .then(data => setStats(data));
    }, []);

    return (
        <div>
            <h2>Statystyki</h2>
            <p>Liczba produktów: {stats.totalProducts}</p>
            <p>Obsłużone przez instancję: {stats.instanceId}</p>
            <p>Aktualny czas serwera: {stats.currentTime}</p>
            <p>Liczba obsłużonych żądań: {stats.requestCount}</p>
            <p>Czas pracy serwera (uptime): {stats.uptime ? Math.floor(stats.uptime) + ' s' : 'Brak danych'}</p>
        </div>
    );
};

export default function App() {
    return (
        <Router>
            <nav>
                <Link to="/">Strona Główna</Link> | <Link to="/products">Produkty</Link> | <Link to="/stats">Statystyki</Link>
            </nav>
            <div>
                <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/products" element={<Products />} />
                    <Route path="/stats" element={<Stats />} />
                </Routes>
            </div>
        </Router>
    );
}