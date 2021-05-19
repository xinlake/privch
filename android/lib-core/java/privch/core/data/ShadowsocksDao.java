package privch.core.data;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.Transaction;
import androidx.room.Update;

import java.util.List;

@Dao
public interface ShadowsocksDao {
    @Query("SELECT COUNT(*) FROM Shadowsocks")
    int getCount();

    @Query("SELECT * FROM Shadowsocks ORDER BY `order` ASC")
    List<Shadowsocks> getAll();

    @Query("SELECT * FROM Shadowsocks WHERE id=:id")
    Shadowsocks getById(int id);

    @Update
    void update(Shadowsocks ss);

    @Update
    void updateAll(List<Shadowsocks> ssList);

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    long insert(Shadowsocks ss);

    @Insert
    void insertAll(List<Shadowsocks> ssList);

    @Delete
    void delete(Shadowsocks ss);

    // Does not support returning boolean values
    @Query("DELETE FROM Shadowsocks WHERE id=:id")
    void delete(int id);


    @Transaction
    @Query("SELECT * FROM Shadowsocks")
    List<ShadowsocksBundle> getBundle();
}
