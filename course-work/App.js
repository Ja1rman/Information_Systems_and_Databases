import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AdsList from './AdsList'; // Ваш компонент со списком объявлений
import AdDetails from './AdDetails'; // Новый компонент с подробностями объявления

const App = () => {
  return (
    <Router>
      <Routes>
        <Route exact path="/" element={<AdsList />} /> {/* Страница со списком объявлений */}
        <Route exact path="/ads/:adID" element={<AdDetails />} /> {/* Страница с подробностями объявления */}
      </Routes>
    </Router>
  );
};

export default App;